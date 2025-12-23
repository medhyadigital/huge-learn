import '../../domain/entities/shloka_translation.dart';

/// Shloka Translation Model (Data Layer)
class ShlokaTranslationModel extends ShlokaTranslation {
  const ShlokaTranslationModel({
    required super.translationId,
    required super.shlokaId,
    required super.language,
    required super.meaning,
    super.explanation,
    super.whyItMatters,
  });

  factory ShlokaTranslationModel.fromJson(Map<String, dynamic> json) {
    return ShlokaTranslationModel(
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

  ShlokaTranslation toEntity() {
    return ShlokaTranslation(
      translationId: translationId,
      shlokaId: shlokaId,
      language: language,
      meaning: meaning,
      explanation: explanation,
      whyItMatters: whyItMatters,
    );
  }
}



