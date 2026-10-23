import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/exceptions/exceptions.dart';

import '../../helpers/fake_api.dart';

void main() {
  Future<ApiException> errorFor(Object? body) async {
    final api = FakeApi()..on('PUT', '/dose', FakeReply(400, body));
    try {
      await api.client.put('/dose');
    } on ApiException catch (e) {
      return e;
    }
    fail('no ApiException thrown');
  }

  test('a validation error with a list of messages keeps its status and text',
      () async {
    final e = await errorFor({
      'statusCode': 400,
      'error': 'Bad Request',
      'message': ['section must be one of MORNING, AFTERNOON, EVENING'],
    });

    expect((e.code, e.message),
        ('400', 'section must be one of MORNING, AFTERNOON, EVENING'));
  });

  test('a plain message is kept as it is', () async {
    final e =
        await errorFor({'statusCode': 400, 'message': "It's not yet time"});

    expect((e.code, e.message), ('400', "It's not yet time"));
  });

  test('an empty body still keeps the status', () async {
    expect((await errorFor(null)).code, '400');
  });
}
