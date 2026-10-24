import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/progress/data/datasources/progress_remote_datasource.dart';

import '../../../helpers/fake_api.dart';

void main() {
  test('trend presets are sent in Accra time, and no groupby',
      () async {
    const path = '/api/v1/client/vital-histories/trends';
    final api = FakeApi()
      ..on('GET', '$path/bp', FakeReply.ok({}))
      ..on('GET', path, FakeReply.ok({}));
    final source = ProgressRemoteDataSource(api.client);

    await source.getBPTrend(dateRange: 'thisWeek');
    await source.getVitalTrend(vitalType: 'bloodSugar', dateRange: 'today');

    expect(api.requests.map((r) => r.queryParameters), [
      {'dateRange': 'thisWeek', 'tz': 'Africa/Accra'},
      {'vitalType': 'bloodSugar', 'dateRange': 'today', 'tz': 'Africa/Accra'},
    ]);
  });
}
