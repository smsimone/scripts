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

  final files = _listSourceFiles(parsed['dir'] as String);
  files.forEach(print);
}

List<File> _listSourceFiles(String projectPath) {
  final dir = Directory(projectPath);

  final pubspec = '${dir.path}/pubspec.yaml';
  if (!File(pubspec).existsSync()) {
    printerr('The "--dir" must be related to a dart project');
    return [];
  }

  return listFiles(projectPath);
}
