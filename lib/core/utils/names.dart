import 'package:flutter/services.dart';

// A lower-case letter at the start of a word (after a space or hyphen).
final _wordStart = RegExp(r'(^|[\s-])(\p{Ll})', unicode: true);

/// [text] with the first letter of each word in capitals; the rest is kept
/// as typed, so names like "McDonald" stay intact.
String capitaliseWords(String text) => text.replaceAllMapped(_wordStart, (m) {
      final upper = m[2]!.toUpperCase();
      // Letters like "ß" grow when capitalised; leave them, so the cursor stays put.
      return upper.length == 1 ? '${m[1]}$upper' : m[0]!;
    });

/// A name ready to save: no spaces around or doubled inside, and each word
/// starting with a capital.
String tidyName(String name) =>
    capitaliseWords(name.trim().replaceAll(RegExp(r'\s+'), ' '));

/// Capitalises the first letter of each word of a name while it is typed or pasted.
class NameInputFormatter extends TextInputFormatter {
  const NameInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: capitaliseWords(newValue.text));
}
