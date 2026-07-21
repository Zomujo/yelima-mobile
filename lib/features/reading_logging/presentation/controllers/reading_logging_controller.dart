import 'package:flutter/material.dart';
import '../../../home/domain/repositories/home_metrics_repository.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/utils/custom_types.dart';
import '../../domain/entities/reading_form_data.dart';
import '../../domain/usecases/save_vital_reading_usecase.dart';
import '../states/reading_logging_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class ReadingLoggingController extends ChangeNotifier with SafeNotifier {
  final HomeMetricsRepository _repository;
  final SaveVitalReadingUseCase _saveVitalReadingUseCase;

  ReadingLoggingController({
    required HomeMetricsRepository repository,
    required SaveVitalReadingUseCase saveVitalReadingUseCase,
  })  : _repository = repository,
        _saveVitalReadingUseCase = saveVitalReadingUseCase;

  ReadingLoggingState _state =
      ReadingLoggingState(selectedDate: DateTime.now());
  ReadingLoggingState get state => _state;

  set state(ReadingLoggingState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Fetches the latest home metrics to prepopulate the reading forms.
  Future<void> init() async {
    final result = await _repository.getHomeMetrics();

    result.fold((_) {}, (metrics) {
      final bp = metrics.parsedBloodPressure;
      final sugar = metrics.parsedBloodGlucose;

      state = state.copyWith(
        systolic: bp?.$1 ?? state.systolic,
        diastolic: bp?.$2 ?? state.diastolic,
        sugarLevel: sugar ?? state.sugarLevel,
      );
    });
  }

  /// Updates the currently selected tab (e.g., Blood Pressure vs. Blood Glucose).
  void setTypeIndex(int index) {
    if (state.selectedTypeIndex != index) {
      state = state.copyWith(selectedTypeIndex: index, hasChanged: false);
    }
  }

  /// Sets the blood pressure readings (systolic and diastolic).
  void setBloodPressure(int sys, int dia) {
    if (state.systolic != sys || state.diastolic != dia) {
      state = state.copyWith(systolic: sys, diastolic: dia, hasChanged: true);
    }
  }

  /// Sets the blood glucose reading level.
  void setSugarLevel(double level) {
    if (state.sugarLevel != level) {
      state = state.copyWith(sugarLevel: level, hasChanged: true);
    }
  }

  /// Updates the selected date while preserving the current time.
  void setSelectedDate(DateTime date) {
    final now = DateTime.now();
    final newDate = DateTime(
        date.year, date.month, date.day, now.hour, now.minute, now.second);

    state = state.copyWith(selectedDate: newDate, hasChanged: true);
  }

  /// Saves the current vital reading to the backend.
  AsyncResponse<void> saveReading() async {
    state = state.copyWith(isSaving: true);

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final formData = ReadingFormData(
          selectedTypeIndex: state.selectedTypeIndex,
          systolic: state.systolic,
          diastolic: state.diastolic,
          sugarLevel: state.sugarLevel,
          recordedAt: state.selectedDate,
        );

        return await _saveVitalReadingUseCase(formData);
      },
      operationName: 'saveReading',
    );

    state = state.copyWith(isSaving: false, hasChanged: response.isLeft());
    return response;
  }
}
