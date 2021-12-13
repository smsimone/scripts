import 'dart:io';
import 'package:dcli/dcli.dart';

import 'model/translation_file.dart';

int main(List<String> arguments) {
  var currentDir = arguments.isEmpty ? pwd : arguments.first;

  final directory = Directory(currentDir);
  if (!directory.existsSync() ||
      !directory.listSync().any((element) => element.path.endsWith('arb'))) {
    printerr('Folder does not contain an arb file or doesn\'t exists');
    return 1;
  }

  final arbFiles =
      directory.listSync().where((element) => element.path.endsWith('arb'));

  print('Found ${arbFiles.length} arb files');

  final files = arbFiles.map((a) => TranslationFile.parse(a.path));

  if (files.every((element) => element.isValid)) {
    print('All files are valid');
    return 0;
  }

  return 0;
}
