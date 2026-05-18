import 'dart:io';

void main() {
  final dir = Directory('lib');
  final regex = RegExp(r"'([^'\\]*[\u4e00-\u9fa5]+[^'\\]*)'(?!\.tr)");
  
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('translations.dart')) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final matches = regex.allMatches(lines[i]);
        if (matches.isNotEmpty) {
          for (var match in matches) {
            print('${file.path}:${i + 1}: ${match.group(0)}');
          }
        }
      }
    }
  }
}
