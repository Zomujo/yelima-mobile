import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/custom_types.dart';
import '../../data/models/dosing_schedule_model.dart';
import '../entities/medicine_form_data.dart';
import '../repositories/medication_repository.dart';
import '../../data/models/create_medication_model.dart';

class CreateMedicationUseCase {
  final MedicationRepository repository;

  const CreateMedicationUseCase(this.repository);

  AsyncResponse<String> call(MedicineFormData data, String medicationName) async {
    if (data.morning == null &&
        data.afternoon == null &&
        data.evening == null) {
      return left('Please select at least one dosing schedule.');
    }

    final createModel = CreateMedicationModel(
      name: medicationName,
      dosage: data.dosage,
      notes: data.notes.isEmpty ? null : data.notes,
      morning: _toModel(data.morning, data.unit),
      afternoon: _toModel(data.afternoon, data.unit),
      evening: _toModel(data.evening, data.unit),
    );

    return repository.createMedication(createModel);
  }

  DosingScheduleModel? _toModel(DoseSchedule? schedule, String unit) {
    if (schedule == null) return null;
    final normalizedHour = schedule.hour == 0 ? 12 : schedule.hour;
    return DosingScheduleModel(
      time: ScheduleTimeModel(
        hour: normalizedHour,
        minutes: schedule.minute,
        timeDesignators: schedule.period,
      ),
      quantity: ScheduleQuantityModel(
        value: schedule.quantity,
        unit: unit,
      ),
    );
  }
}
