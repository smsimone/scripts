import 'dart:convert';
import 'dart:io';

import 'translation_entry.dart';

class TranslationFile {
  TranslationFile._({
    required this.language,
    required this.entries,
  });

  factory TranslationFile.parse(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        throw Exception('File does not exist');
      }

      final contentAsMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final keys = contentAsMap.keys.toList();

      final entries = keys.where((k) => !k.startsWith('@')).map((key) {
        final value = contentAsMap[key] as String?;

        final metadata = contentAsMap['@$key'] as Map<String, dynamic>?;

        return TranslationEntry(
          key: key,
          value: value,
          description: metadata?['description'] as String?,
          placeHolders: (metadata?['placeholders'] as Map<String, dynamic>?)
              ?.keys
              .toList(),
        );
      }).toList();

      return TranslationFile._(
        language: file.path.split('/').last.split('.').first,
        entries: entries,
      );
    } catch (e) {
      print('Failed to parse translation file: $e');
      rethrow;
    }
  }

  final String language;
  final List<TranslationEntry> entries;

  bool get isValid {
    final validities =
        entries.map((e) => e.isValid(language: language)).toList();

    return validities.every((val) => val);
  }
}
