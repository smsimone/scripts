class TranslationEntry {
  TranslationEntry({
    required this.key,
    this.value,
    this.description,
    this.placeHolders,
  });

  final String key;
  final String? value;
  final String? description;
  final List<String>? placeHolders;

  bool isValid({String? language}) {
    if (value == null) {
      return false;
    }

    final regex = RegExp("(^{(?<selector>.*?),|{(?<placeholder>.*?)})");

    if (regex.hasMatch(value!)) {
      if (placeHolders == null) {
        print(
            'Key "$key" ${language == null ? '' : 'for language "$language"'} has placeholders but no placeholders provided');
        return false;
      }

      final stack = [...placeHolders ?? []];

      regex.allMatches(value!).forEach((match) {
        final selector = match.namedGroup('selector');
        final placeholder = match.namedGroup('placeholder');

        stack.removeWhere(
          (element) => element == (selector ?? placeholder),
        );
      });

      if (stack.isNotEmpty) {
        print('Key "$key" missing placeholders: $stack');
        return false;
      }
      return true;
    }
    return true;
  }
}
