import 'dart:convert';

import '../../domain/entities/vital_trends.dart';

BPTrend parseBpTrend(String jsonStr) => BPTrend.fromJson(jsonDecode(jsonStr));
VitalTrend parseVitalTrend(String jsonStr) => VitalTrend.fromJson(jsonDecode(jsonStr));
