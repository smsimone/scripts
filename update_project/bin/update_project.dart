import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser
    ..addOption(
      'directory',
      abbr: 'd',
      help: 'The directory of the project',
    )
    ..addFlag(
      'major',
      abbr: 'm',
      defaultsTo: false,
      help:
          'Launches the `flutter pub upgrade` command with `--major-versions` flag',
    );

  final args = parser.parse(arguments);

  final directory = args['directory'] as String? ?? '.';

  final packagesFound = find('$directory/pubspec.yaml').toList();

  print('Found ${packagesFound.length} package(s)');

  /// Orders to put as first the sub-packages then the main one
  packagesFound.sort((s1, s2) => s2.length.compareTo(s1.length));

  final major = args['major'] as bool;

  for (final pkg in packagesFound) {
    final folder = File(pkg);

    'flutter pub upgrade ${major ? '--major-versions' : ''}'.start(
      workingDirectory: folder.parent.path,
      progress: Progress(echo),
    );
  }
}
