/// Stable notification id for a medication's section reminder.
///
/// Uses 32-bit FNV-1a instead of `String.hashCode`, which Dart doesn't keep the
/// same across SDK versions. Masked to a positive 31-bit int, as Android requires.
int medicationReminderId(String medicationId, String section) {
  var hash = 0x811c9dc5;
  for (final unit in '$medicationId|$section'.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
