import 'package:equatable/equatable.dart';

/// Shloka Translation Entity
class ShlokaTranslation extends Equatable {
  final String translationId;
  final String shlokaId;
  final String language; // 'en', 'hi', 'sa'
  final String meaning;
  final String? explanation;
  final String? whyItMatters;

  const ShlokaTranslation({
    required this.translationId,
    required this.shlokaId,
    required this.language,
    required this.meaning,
    this.explanation,
    this.whyItMatters,
  });

  @override
  List<Object?> get props => [
        translationId,
        shlokaId,
        language,
        meaning,
        explanation,
        whyItMatters,
      ];

  factory ShlokaTranslation.fromJson(Map<String, dynamic> json) {
    return ShlokaTranslation(
      translationId: json['translationId'] as String,
      shlokaId: json['shlokaId'] as String,
      language: json['language'] as String,
      meaning: json['meaning'] as String,
      explanation: json['explanation'] as String?,
      whyItMatters: json['whyItMatters'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'translationId': translationId,
      'shlokaId': shlokaId,
      'language': language,
      'meaning': meaning,
      'explanation': explanation,
      'whyItMatters': whyItMatters,
    };
  }
}



