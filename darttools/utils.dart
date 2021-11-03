import 'dart:io';

import 'package:dcli/dcli.dart';

List<File> listFiles(
  String projectPath, {
  String pattern = '*.dart',
}) {
  final progress = find(pattern, workingDirectory: projectPath);
  final paths = progress.toList();
  return paths.map((e) => File(e)).toList();
}

/// Returns `true` if the directory specified as [path]
/// is a valid flutter project (contains a pubspec.yaml file)
bool isFlutterProject(String path) {
  final content = Directory(path).listSync();
  return content.any((element) => element.path.contains('pubspec.yaml'));
}

class Tuple<T, K> {
  Tuple(this.first, this.second);
  T first;
  K second;

  @override
  String toString() => '$first: $second';
}
