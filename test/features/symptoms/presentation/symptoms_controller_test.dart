import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:yelima/features/symptoms/domain/repositories/symptoms_repository.dart';
import 'package:yelima/features/symptoms/presentation/controllers/symptoms_controller.dart';
import 'package:yelima/features/symptoms/symptoms_providers.dart';

class MockRepo extends Mock implements SymptomsRepository {}

void main() {
  late MockRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockRepo();
    when(() => repo.refresh(force: any(named: 'force')))
        .thenAnswer((_) async => right(null));
    container = ProviderContainer(
        overrides: [symptomsRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
  });

  test('groups symptoms by day, newest first', () async {
    SymptomEntity s(String id, DateTime at) =>
        SymptomEntity(id: id, description: id, onsetDate: at);
    when(() => repo.watchSymptoms()).thenAnswer((_) => Stream.value([
          s('a', DateTime(2026, 10, 22, 9)),
          s('b', DateTime(2026, 10, 23, 8)),
          s('c', DateTime(2026, 10, 23, 20)),
        ]));
    expect(container.read(symptomsControllerProvider).symptoms, isNull,
        reason: 'loading');

    await pumpEventQueue();

    expect(
        container
            .read(symptomsControllerProvider)
            .byDay
            .map((g) => '${g.$1.day}: ${g.$2.map((x) => x.id).join(',')}'),
        ['23: c,b', '22: a']);
  });

  test('asks the server once it is first used', () async {
    when(() => repo.watchSymptoms()).thenAnswer((_) => const Stream.empty());
    container.read(symptomsControllerProvider);

    await pumpEventQueue();

    verify(() => repo.refresh(force: false)).called(1);
    expect(container.read(symptomsControllerProvider).refreshing, isFalse);
  });
}
