#! /usr/bin/env dcli

import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

import 'utils.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Logs additional details to the cli',
    )
    ..addOption(
      'project',
      abbr: 'p',
      help: 'The project directory on which launch the script',
    )
    ..addOption(
      'assets',
      abbr: 'a',
      defaultsTo: 'assets',
      help: 'The assets folder',
    )
    ..addOption(
      'source',
      abbr: 's',
      defaultsTo: 'lib',
      help: 'The folder containing all the source code',
    );

  final parsed = parser.parse(args);

  if (parsed.wasParsed('verbose')) {
    Settings().setVerbose(enabled: true);
  }

  if (!parsed.wasParsed('project')) {
    printerr(red('Missing --project <path> flag'));
    exit(-1);
  }

  final prjDir = Directory(parsed['project'] as String);

  /// Checks if the `--project` path is valid
  if (!isFlutterProject(prjDir.path)) {
    printerr(
      red('The directory specified does not point to a flutter project'),
    );
    exit(-1);
  }
  final assetsDirectory = parsed['assets'] as String;
  final sourceDirectory = parsed['source'] as String;

  /// Checks if `--assets` folder name exists
  if (!Directory('${prjDir.path}/$assetsDirectory').existsSync()) {
    printerr(
      red("Assets directory $assetsDirectory doesn't exist"),
    );
    exit(-1);
  }

  /// Checks if `--source` folder name exists
  if (!Directory('${prjDir.path}/$sourceDirectory').existsSync()) {
    printerr(
      red("Source directory $sourceDirectory doesn't exist"),
    );
    exit(-1);
  }

  final assets = _getAssets('${prjDir.path}/$assetsDirectory');

  print(green('Found ${assets.length} assets'));

  final sourceFiles = listFiles('${prjDir.path}/$sourceDirectory');
  print(green('Found ${sourceFiles.length} source files'));

  final assetsUsed = <String, int>{};

  assets.forEach((asset) {
    final relativePath = asset.replaceAll('${prjDir.path}/', '');

    // print(orange("Looking for '$relativePath'"));

    final count = sourceFiles.where((sourceFile) {
      return sourceFile.readAsStringSync().contains(relativePath);
    }).length;

    assetsUsed[relativePath] = count;
  });

  assetsUsed.removeWhere((key, value) => value > 0);

  print(green('Found ${assetsUsed.length} unused assets:'));
  assetsUsed.forEach((key, value) => print(red(key)));
}

/// Returns a list of all assets contained in [path] folder
List<String> _getAssets(String path) {
  final names = <String>[];
  'find $path -type f'.forEach(names.add);
  return names;
}
