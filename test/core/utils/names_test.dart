import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/utils/names.dart';

void main() {
  group('capitaliseWords', () {
    test('capitalises the first letter of each word', () {
      expect(capitaliseWords('kofi'), 'Kofi');
      expect(capitaliseWords('ama serwaa'), 'Ama Serwaa');
      expect(capitaliseWords('abu-bakr'), 'Abu-Bakr');
    });

    test('keeps capitals the patient typed inside a word', () {
      expect(capitaliseWords('mcDonald'), 'McDonald');
      expect(capitaliseWords('KOFI'), 'KOFI');
    });

    test('leaves letters that grow when capitalised', () {
      expect(capitaliseWords('ßa'), 'ßa');
    });
  });

  group('tidyName', () {
    test('trims, collapses spaces and capitalises', () {
      expect(tidyName('  kofi   mensah  '), 'Kofi Mensah');
      expect(tidyName('\temy\n'), 'Emy');
    });

    test('an all-space name becomes empty', () {
      expect(tidyName('   '), '');
    });
  });

  test('NameInputFormatter capitalises as the patient types, cursor unchanged',
      () {
    const formatter = NameInputFormatter();
    final out = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
          text: 'kofi m', selection: TextSelection.collapsed(offset: 6)),
    );
    expect(out.text, 'Kofi M');
    expect(out.selection, const TextSelection.collapsed(offset: 6));
  });
}
