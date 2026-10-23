import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';

void main() {
  test('ACC-EC-04: registration status only ever moves forward', () {
    expect(RegistrationStatus.personalDetails.atLeast(RegistrationStatus.dob),
        RegistrationStatus.dob);
    expect(RegistrationStatus.complete.atLeast(RegistrationStatus.dob),
        RegistrationStatus.complete);
    expect(RegistrationStatus.dob.atLeast(RegistrationStatus.dob),
        RegistrationStatus.dob);
  });
}
