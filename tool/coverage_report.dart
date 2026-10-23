// Prints line coverage per feature from coverage/lcov.info.
// Run: flutter test --coverage && dart tool/coverage_report.dart
// Files no test loads are missing from lcov, so "files" shows how many each area touches.
import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('No coverage/lcov.info. Run: flutter test --coverage');
    exit(1);
  }

  final hit = <String, int>{};
  final found = <String, int>{};
  final loaded = <String, int>{};
  final total = <String, int>{};
  String? area;

  for (final f
      in Directory('lib').listSync(recursive: true).whereType<File>()) {
    final a = f.path.endsWith('.dart') ? _areaOf(f.path) : null;
    if (a != null) total[a] = (total[a] ?? 0) + 1;
  }

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      area = _areaOf(line.substring(3));
      if (area != null) loaded[area] = (loaded[area] ?? 0) + 1;
    } else if (area != null && line.startsWith('LH:')) {
      hit[area] = (hit[area] ?? 0) + int.parse(line.substring(3));
    } else if (area != null && line.startsWith('LF:')) {
      found[area] = (found[area] ?? 0) + int.parse(line.substring(3));
    }
  }

  final areas = total.keys.toList()..sort();
  var sums = (0, 0, 0, 0);
  stdout.writeln(
      '${'area'.padRight(26)}${'lines'.padLeft(9)}${'of'.padLeft(7)}${'files'.padLeft(10)}');
  for (final a in areas) {
    final r = (hit[a] ?? 0, found[a] ?? 0, loaded[a] ?? 0, total[a]!);
    sums = (sums.$1 + r.$1, sums.$2 + r.$2, sums.$3 + r.$3, sums.$4 + r.$4);
    stdout.writeln(_row(a, r));
  }
  stdout.writeln(_row('TOTAL', sums));
}

/// Groups a source path into `features/<name>`, `core/<name>` or `shared`; null skips generated code.
String? _areaOf(String path) {
  final p = path.replaceAll('\\', '/');
  if (RegExp(r'\.(g|freezed)\.dart$').hasMatch(p)) return null;
  final m = RegExp(r'lib/(features|core)/([^/]+)/').firstMatch(p);
  if (m != null) return '${m[1]}/${m[2]}';
  return p.contains('lib/shared/') ? 'shared' : 'app';
}

/// One report line: line coverage of loaded files, then files loaded out of all files.
String _row(String area, (int, int, int, int) r) {
  final (hit, found, loaded, files) = r;
  final pct = found == 0 ? 0 : hit * 100 / found;
  return '${area.padRight(26)}${'${pct.toStringAsFixed(1)}%'.padLeft(9)}'
      '${'$found'.padLeft(7)}${'$loaded/$files'.padLeft(10)}';
}
