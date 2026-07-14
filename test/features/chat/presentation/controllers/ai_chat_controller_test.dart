import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:yelima/core/services/mutation_sync_manager.dart';
import 'package:yelima/features/chat/data/repositories/ai_chat_repository_impl.dart';
import 'package:yelima/features/chat/domain/entities/ai_chat_message.dart';
import 'package:yelima/features/chat/presentation/controllers/ai_chat_controller.dart';

import 'package:yelima/features/chat/domain/repositories/ai_chat_repository.dart';

class MockAiChatRepository extends Mock implements AiChatRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockMutationSyncManager extends Mock implements MutationSyncManager {}

void main() {
  late MockAiChatRepository mockRepository;
  late MockConnectivityService mockConnectivityService;
  late MockMutationSyncManager mockMutationSyncManager;

  AiChatMessage botMessage(String id, {String value = 'bot reply'}) {
    return AiChatMessage(
      id: id,
      sender: 'bot',
      type: MessageType.text,
      value: value,
      createdAt: DateTime(2026, 1, 1),
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> chatResponse({
    required String userId,
    required String botId,
    String botText = 'hi',
  }) {
    return {
      'data': {
        'inResponse': {'_id': userId},
        'outResponse': {'_id': botId, 'text': botText, 'suggestions': []},
      },
    };
  }

  setUp(() {
    mockRepository = MockAiChatRepository();
    mockConnectivityService = MockConnectivityService();
    mockMutationSyncManager = MockMutationSyncManager();

    when(() => mockMutationSyncManager.onMutationSynced)
        .thenAnswer((_) => const Stream.empty());

    when(() => mockConnectivityService.isConnected)
        .thenAnswer((_) async => true);
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => const Stream<bool>.empty());

    when(() => mockRepository.saveConversations(any()))
        .thenAnswer((_) async => right(null));
    when(() => mockRepository.syncRemoteConversations())
        .thenAnswer((_) async => right(null));
    when(() => mockRepository.loadInitialMessage())
        .thenAnswer((_) async => right(null));
    when(() => mockRepository.deleteLocalMessageOnly(any()))
        .thenAnswer((_) async => right(null));
  });

  Future<AiChatController> createController({
    List<AiChatMessage> initialMessages = const [],
  }) async {
    when(() => mockRepository.loadConversations())
        .thenAnswer((_) async => right(initialMessages));
    final controller =
        AiChatController(mockRepository, mockConnectivityService, mockMutationSyncManager);
    // Let the constructor's fire-and-forget initial syncConversations() settle.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return controller;
  }

  group('AiChatController duplicate-message regression', () {
    test(
        'sendMessage upserts the bot reply instead of duplicating a message id already in _messages',
        () async {
      // Simulate a bot message that's already present in _messages (e.g.
      // pulled in by a resync) sharing the id the send response will report.
      final controller = await createController(
        initialMessages: [botMessage('bot-1', value: 'already there')],
      );

      when(() => mockRepository.sendMessage(any(),
              localChatId: any(named: 'localChatId')))
          .thenAnswer((_) async =>
              right(chatResponse(userId: 'user-1', botId: 'bot-1', botText: 'updated reply')));

      await controller.sendMessage('Hello');

      final botEntries =
          controller.messages.where((m) => m.id == 'bot-1').toList();
      expect(botEntries, hasLength(1));
      expect(botEntries.single.value, 'updated reply');

      controller.dispose();
    });

    test(
        'syncConversations defers while a send is in flight and runs afterward instead of racing it',
        () async {
      final controller = await createController();

      var loadConversationsCallCount = 0;
      when(() => mockRepository.loadConversations()).thenAnswer((_) async {
        loadConversationsCallCount++;
        return right(<AiChatMessage>[]);
      });

      final sendCompleter = Completer<Either<String, Map<String, dynamic>>>();
      when(() => mockRepository.sendMessage(any(),
              localChatId: any(named: 'localChatId')))
          .thenAnswer((_) => sendCompleter.future);

      final sendFuture = controller.sendMessage('Hello');
      await Future<void>.delayed(Duration.zero);
      expect(controller.isSending, isTrue);

      // A connectivity-triggered resync fires while the send is still pending.
      await controller.syncConversations();

      // It must not touch the repository while the send owns _messages.
      expect(loadConversationsCallCount, 0);

      sendCompleter
          .complete(right(chatResponse(userId: 'user-1', botId: 'bot-1')));
      await sendFuture;

      // Let the deferred sync (triggered from sendMessage's finally block) run.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(loadConversationsCallCount, greaterThanOrEqualTo(1));
      expect(controller.isSending, isFalse);

      controller.dispose();
    });

    test('sendMessage waits for an in-flight sync before touching _messages',
        () async {
      final controller = await createController();

      final syncCompleter = Completer<void>();
      when(() => mockRepository.loadConversations())
          .thenAnswer((_) => syncCompleter.future.then((_) => right(<AiChatMessage>[])));

      when(() => mockRepository.sendMessage(any(),
              localChatId: any(named: 'localChatId')))
          .thenAnswer((_) async => right(chatResponse(userId: 'user-1', botId: 'bot-1')));

      final syncFuture = controller.syncConversations();
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoading, isTrue);

      // A send comes in while the sync is still rewriting _messages.
      final sendFuture = controller.sendMessage('Hello');
      await Future<void>.delayed(Duration.zero);

      // isSending is claimed immediately (so a second tap is rejected), but
      // the optimistic message must not be added until the sync finishes.
      expect(controller.isSending, isTrue);
      expect(controller.messages.any((m) => m.value == 'Hello'), isFalse);

      syncCompleter.complete();
      await syncFuture;
      await sendFuture;

      expect(
          controller.messages
              .any((m) => m.id == 'user-1' && m.status == MessageStatus.sent),
          isTrue,
          reason: 'send should proceed normally once the sync finishes');
      expect(controller.messages.any((m) => m.id == 'bot-1'), isTrue);

      controller.dispose();
    });

    test(
        'syncConversations defers while loadMoreMessages is in flight and runs afterward instead of racing it',
        () async {
      final controller = await createController();

      var loadConversationsCallCount = 0;
      when(() => mockRepository.loadConversations()).thenAnswer((_) async {
        loadConversationsCallCount++;
        return right(<AiChatMessage>[]);
      });

      final pageCompleter = Completer<Either<String, PaginatedChatResult>>();
      when(() => mockRepository.fetchPaginatedConversations(
              page: any(named: 'page')))
          .thenAnswer((_) => pageCompleter.future);

      final loadMoreFuture = controller.loadMoreMessages();
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoadingMore, isTrue);

      // A connectivity-triggered resync fires while pagination is in flight.
      await controller.syncConversations();

      // It must not touch the repository (or _currentPage) while
      // loadMoreMessages owns _messages.
      expect(loadConversationsCallCount, 0);

      pageCompleter.complete(
          right(PaginatedChatResult(messages: [botMessage('bot-2')], totalPages: 5)));
      await loadMoreFuture;

      // Let the deferred sync (triggered from loadMoreMessages's finally
      // block) run.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(loadConversationsCallCount, greaterThanOrEqualTo(1));
      expect(controller.isLoadingMore, isFalse);

      controller.dispose();
    });

    test(
        'loadMoreMessages waits for an in-flight sync before touching _messages/_currentPage',
        () async {
      final controller = await createController();

      final syncCompleter = Completer<void>();
      when(() => mockRepository.loadConversations()).thenAnswer(
          (_) => syncCompleter.future.then((_) => right(<AiChatMessage>[])));

      when(() => mockRepository.fetchPaginatedConversations(
              page: any(named: 'page')))
          .thenAnswer((_) async =>
              right(PaginatedChatResult(messages: [botMessage('bot-2')], totalPages: 5)));

      final syncFuture = controller.syncConversations();
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoading, isTrue);

      // A scroll-triggered pagination fetch comes in while the sync is still
      // rewriting _messages and _currentPage.
      final loadMoreFuture = controller.loadMoreMessages();
      await Future<void>.delayed(Duration.zero);

      // isLoadingMore is claimed immediately (so a second scroll event is
      // rejected), but the page fetch/merge must not run until the sync
      // finishes.
      expect(controller.isLoadingMore, isTrue);
      expect(controller.messages.any((m) => m.id == 'bot-2'), isFalse);

      syncCompleter.complete();
      await syncFuture;
      await loadMoreFuture;

      expect(controller.messages.any((m) => m.id == 'bot-2'), isTrue,
          reason: 'pagination should proceed normally once the sync finishes');

      controller.dispose();
    });
  });
}
