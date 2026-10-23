import 'package:yelima/features/chat/domain/entities/paginated_chat_result.dart';
import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/chat/domain/entities/ai_chat_message.dart';
import 'package:yelima/features/chat/presentation/controllers/ai_chat_controller.dart';

import 'package:yelima/features/chat/domain/repositories/ai_chat_repository.dart';

class MockAiChatRepository extends Mock implements AiChatRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockAiChatRepository mockRepository;
  late MockConnectivityService mockConnectivityService;

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

  /// The server's answer: the user message's id and the bot reply.
  ChatReply chatResponse({
    required String userId,
    required String botId,
    String botText = 'hi',
  }) =>
      ChatReply(userMessageId: userId, bot: botMessage(botId, value: botText));

  setUp(() {
    mockRepository = MockAiChatRepository();
    mockConnectivityService = MockConnectivityService();
    when(() => mockRepository.onSynced).thenAnswer((_) => const Stream.empty());

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
        AiChatController(mockRepository, mockConnectivityService);
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
          .thenAnswer((_) async => right(chatResponse(
              userId: 'user-1', botId: 'bot-1', botText: 'updated reply')));

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

      final sendCompleter = Completer<Either<AppFailure, ChatReply>>();
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
      when(() => mockRepository.loadConversations()).thenAnswer(
          (_) => syncCompleter.future.then((_) => right(<AiChatMessage>[])));

      when(() =>
          mockRepository.sendMessage(any(),
              localChatId: any(named: 'localChatId'))).thenAnswer(
          (_) async => right(chatResponse(userId: 'user-1', botId: 'bot-1')));

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

      final pageCompleter =
          Completer<Either<AppFailure, PaginatedChatResult>>();
      when(() => mockRepository.fetchPaginatedConversations(
          page: any(named: 'page'))).thenAnswer((_) => pageCompleter.future);

      final loadMoreFuture = controller.loadMoreMessages();
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoadingMore, isTrue);

      // A connectivity-triggered resync fires while pagination is in flight.
      await controller.syncConversations();

      // It must not touch the repository (or _currentPage) while
      // loadMoreMessages owns _messages.
      expect(loadConversationsCallCount, 0);

      pageCompleter.complete(right(
          PaginatedChatResult(messages: [botMessage('bot-2')], totalPages: 5)));
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

      when(() =>
          mockRepository.fetchPaginatedConversations(
              page: any(named: 'page'))).thenAnswer((_) async => right(
          PaginatedChatResult(messages: [botMessage('bot-2')], totalPages: 5)));

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

  test('CHAT-EC-01: a reply that lands after the chat closes is not saved',
      () async {
    final controller = await createController();
    clearInteractions(mockRepository);
    final reply = Completer<Either<AppFailure, ChatReply>>();
    when(() => mockRepository.sendMessage(any(),
            localChatId: any(named: 'localChatId')))
        .thenAnswer((_) => reply.future);

    final sending = controller.sendMessage('Hello');
    await Future<void>.delayed(Duration.zero);
    controller.dispose(); // e.g. logout pops the chat screen
    reply.complete(right(chatResponse(userId: 'user-1', botId: 'bot-1')));
    await sending;

    verifyNever(() => mockRepository.saveConversations(any()));
  });

  test('offline during a background sync shows no error', () async {
    when(() => mockRepository.loadInitialMessage())
        .thenAnswer((_) async => left(const NetworkFailure()));

    final controller = await createController();
    await pumpEventQueue();

    expect(controller.error, isNull);
    controller.dispose();
  });

  test('a queued send stays "sending" until it syncs', () async {
    final controller = await createController();
    when(() => mockRepository.sendMessage(any(),
            localChatId: any(named: 'localChatId')))
        .thenAnswer((_) async => right(const ChatReply.queued()));

    await controller.sendMessage('Hello');

    expect(controller.messages.single.status, MessageStatus.sending);
    controller.dispose();
  });
}
