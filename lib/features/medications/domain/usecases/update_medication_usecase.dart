import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/custom_types.dart';
import '../entities/medicine_form_data.dart';
import '../repositories/medication_repository.dart';
import '../../data/models/update_medication_model.dart';
import '../../data/models/dosing_schedule_model.dart';

class UpdateMedicationUseCase {
  final MedicationRepository repository;

  const UpdateMedicationUseCase(this.repository);

  AsyncResponse<String> call(
      String medicationId, MedicineFormData data) async {
    if (data.morning == null &&
        data.afternoon == null &&
        data.evening == null) {
      return left('Please select at least one dosing schedule.');
    }

    final updateModel = UpdateMedicationModel(
      dosage: data.dosage,
      notes: data.notes,
      morning: _toModel(data.morning, data.unit),
      afternoon: _toModel(data.afternoon, data.unit),
      evening: _toModel(data.evening, data.unit),
    );

    return repository.updateMedication(medicationId, updateModel);
  }

  DosingScheduleModel? _toModel(DoseSchedule? schedule, String unit) {
    if (schedule == null) return null;
    // Normalize hour: 0 becomes 12 (12-hour clock convention for midnight/noon)
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
