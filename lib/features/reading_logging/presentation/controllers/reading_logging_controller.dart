import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import '../../../home/domain/repositories/home_metrics_repository.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/custom_types.dart';
import '../../domain/entities/reading_form_data.dart';
import '../../domain/usecases/save_vital_reading_usecase.dart';
import '../states/reading_logging_state.dart';

class ReadingLoggingController extends ChangeNotifier {
  final HomeMetricsRepository _repository;
  final SaveVitalReadingUseCase _saveVitalReadingUseCase;
  final INetworkInfo _networkInfo;

  ReadingLoggingController({
    required HomeMetricsRepository repository,
    required SaveVitalReadingUseCase saveVitalReadingUseCase,
    required INetworkInfo networkInfo,
  })  : _repository = repository,
        _saveVitalReadingUseCase = saveVitalReadingUseCase,
        _networkInfo = networkInfo;

  bool _isDisposed = false;

  ReadingLoggingState _state =
      ReadingLoggingState(selectedDate: DateTime.now());
  ReadingLoggingState get state => _state;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> init() async {
    final result = await _repository.getHomeMetrics();

    if (_isDisposed) return;

    result.fold(
      (_) {},
      (metrics) {
        int? initialSys;
        int? initialDia;
        double? initialSugar;

        if (metrics.bloodPressure != null &&
            metrics.bloodPressure!.isNotEmpty &&
            !metrics.bloodPressure!.contains('--')) {
          final parts = metrics.bloodPressure!.split('/');
          if (parts.length == 2) {
            final sys = int.tryParse(parts[0].trim());
            final dia = int.tryParse(parts[1].trim());
            if (sys != null && dia != null) {
              initialSys = sys;
              initialDia = dia;
            }
          }
        }
        if (metrics.bloodGlucose != null &&
            metrics.bloodGlucose!.isNotEmpty &&
            !metrics.bloodGlucose!.contains('--')) {
          final level = double.tryParse(metrics.bloodGlucose!.trim());
          if (level != null) {
            initialSugar = level;
          }
        }

        _state = _state.copyWith(
          systolic: initialSys ?? _state.systolic,
          diastolic: initialDia ?? _state.diastolic,
          sugarLevel: initialSugar ?? _state.sugarLevel,
        );

        if (!_isDisposed) notifyListeners();
      },
    );
  }

  void setTypeIndex(int index) {
    if (_state.selectedTypeIndex != index) {
      _state = _state.copyWith(
        selectedTypeIndex: index,
        hasChanged: false, // reset when switching tabs
      );
      notifyListeners();
    }
  }

  void setBloodPressure(int sys, int dia) {
    if (_state.systolic != sys || _state.diastolic != dia) {
      _state = _state.copyWith(
        systolic: sys,
        diastolic: dia,
        hasChanged: true,
      );
      notifyListeners();
    }
  }

  void setSugarLevel(double level) {
    if (_state.sugarLevel != level) {
      _state = _state.copyWith(
        sugarLevel: level,
        hasChanged: true,
      );
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    // Preserve the current time if the user picks a new day
    final now = DateTime.now();
    final newDate = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
    );
    _state = _state.copyWith(
      selectedDate: newDate,
      hasChanged: true,
    );
    notifyListeners();
  }

  AsyncResponse<void> saveReading() async {
    _state = _state.copyWith(isSaving: true);
    if (!_isDisposed) notifyListeners();

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final isConnected = await _networkInfo.isConnected;
        if (!isConnected) {
          return left(
              'No internet connection. Please check your network and try again.');
        }

        final formData = ReadingFormData(
          selectedTypeIndex: _state.selectedTypeIndex,
          systolic: _state.systolic,
          diastolic: _state.diastolic,
          sugarLevel: _state.sugarLevel,
          recordedAt: _state.selectedDate,
        );

        return await _saveVitalReadingUseCase(formData);
      },
      operationName: 'saveReading',
    );

    _state = _state.copyWith(
      isSaving: false,
      hasChanged: response.isLeft(), // Reset hasChanged if successful
    );
    if (!_isDisposed) notifyListeners();

    return response;
  }
}
