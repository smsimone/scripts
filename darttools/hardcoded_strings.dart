#! /usr/bin/env dcli

import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

import 'utils.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'dir',
      abbr: 'd',
      help: 'The project directory.',
      mandatory: true,
    );

  final parsed = parser.parse(args);

  final directory = parsed['dir'] as String;
  final sourceFiles = listFiles(directory);
  print(green('[HardcodedStrings] Found ${sourceFiles.length} source files'));
  print(green('[HardcodedStrings] Starting search'));
  final hardCodedStrings = sourceFiles
      .map(
        (e) => Tuple(e.path, _hardcodedStrings(e)),
      )
      .toList();

  hardCodedStrings.where((element) => element.second.isNotEmpty).toList()
    ..sort((t1, t2) => t1.second.length.compareTo(t2.second.length))
    ..forEach((element) {
      final msg =
          // ignore: lines_longer_than_80_chars
          'File ${element.first} has ${element.second.length} hardcoded strings';
      print(red(msg));
    });
}

List<String> _hardcodedStrings(File file) {
  final allStrings = <String>[];

  cat(file.path, stdout: allStrings.add);

  final hardcoded = allStrings.where((line) {
    if ([
      'import',
      'logger',
      'debugPrint',
      'Exception',
      '///',
      'case',
      '[',
      '=='
    ].any(
      (item) => line.contains(item),
    )) {
      return false;
    }

    /// Checks if the strings is like a map entry
    {
      final regex = RegExp(': .*,');
      if (regex.hasMatch(line)) return false;
    }
    {
      /// Checks if the strings is a map lookup
      {
        final regex = RegExp("['[.*]']");
        if (regex.hasMatch(line)) return false;
      }
    }
    return line.contains("'") || line.contains('"');
  }).toList();

  return hardcoded;
}
