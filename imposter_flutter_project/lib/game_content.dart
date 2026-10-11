import 'dart:convert';

import 'package:flutter/services.dart';

class GameContent {
  const GameContent({required this.entries});

  final List<GameWord> entries;

  factory GameContent.fromJson(Map<String, dynamic> json) {
    final value = json['words'];
    if (value is! List || value.isEmpty) {
      throw FormatException(
        'Jede Kategorie braucht mindestens ein Wort-Tipp-Paar.',
      );
    }

    return GameContent(
      entries: List<GameWord>.unmodifiable(
        value.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'Jedes Wort muss ein Objekt mit "word" und "tip" sein.',
            );
          }
          return GameWord.fromJson(item);
        }),
      ),
    );
  }
}

class GameWord {
  const GameWord({required this.word, required this.tip});

  final String word;
  final String tip;

  factory GameWord.fromJson(Map<String, dynamic> json) {
    final word = json['word'];
    final tip = json['tip'];
    if (word is! String || word.trim().isEmpty) {
      throw const FormatException(
        'Jedes Wort-Tipp-Paar braucht ein nicht leeres "word".',
      );
    }
    if (tip is! String || tip.trim().isEmpty) {
      throw const FormatException(
        'Jedes Wort-Tipp-Paar braucht einen nicht leeren "tip".',
      );
    }

    return GameWord(word: word, tip: tip);
  }
}

Future<Map<String, GameContent>> loadGameContent() async {
  final jsonString = await rootBundle.loadString('assets/game_content.json');
  final decoded = jsonDecode(jsonString);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Die JSON-Datei muss ein Objekt mit Kategorien enthalten.',
    );
  }

  final content = <String, GameContent>{};
  for (final entry in decoded.entries) {
    if (entry.value is! Map<String, dynamic>) {
      throw FormatException(
        'Die Kategorie "${entry.key}" muss ein Objekt sein.',
      );
    }
    content[entry.key] = GameContent.fromJson(entry.value);
  }

  if (content.isEmpty) {
    throw const FormatException('Die JSON-Datei enthält keine Kategorien.');
  }
  return Map<String, GameContent>.unmodifiable(content);
}
