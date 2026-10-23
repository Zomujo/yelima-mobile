import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:yelima/features/symptoms/domain/repositories/symptoms_repository.dart';
import 'package:yelima/features/symptoms/presentation/controllers/symptoms_controller.dart';

class MockRepo extends Mock implements SymptomsRepository {}

void main() {
  test('groups symptoms by day, newest first', () async {
    final repo = MockRepo();
    SymptomEntity s(String id, DateTime at) =>
        SymptomEntity(id: id, description: id, onsetDate: at);
    when(() => repo.watchSymptoms()).thenAnswer((_) => Stream.value([
          s('a', DateTime(2026, 10, 22, 9)),
          s('b', DateTime(2026, 10, 23, 8)),
          s('c', DateTime(2026, 10, 23, 20)),
        ]));
    final controller = SymptomsController(repository: repo);
    addTearDown(controller.dispose);
    expect(controller.state.symptoms, isNull, reason: 'loading');

    await pumpEventQueue();

    expect(
        controller.byDay
            .map((g) => '${g.$1.day}: ${g.$2.map((x) => x.id).join(',')}'),
        ['23: c,b', '22: a']);
  });
}
