import 'package:equatable/equatable.dart';
import 'gita_chapter.dart';
import 'shloka_translation.dart';
import 'shloka_audio.dart';

/// Gita Shloka Entity
class GitaShloka extends Equatable {
  final String shlokaId;
  final int shlokaNumber;
  final String sanskritText;
  final String? transliteration;
  final int xpReward;
  final GitaChapter? chapter;
  final List<ShlokaTranslation> translations;
  final List<ShlokaAudio> audioFiles;

  const GitaShloka({
    required this.shlokaId,
    required this.shlokaNumber,
    required this.sanskritText,
    this.transliteration,
    required this.xpReward,
    this.chapter,
    this.translations = const [],
    this.audioFiles = const [],
  });

  @override
  List<Object?> get props => [
        shlokaId,
        shlokaNumber,
        sanskritText,
        transliteration,
        xpReward,
        chapter,
        translations,
        audioFiles,
      ];

  factory GitaShloka.fromJson(Map<String, dynamic> json) {
    return GitaShloka(
      shlokaId: json['shlokaId'] as String,
      shlokaNumber: json['shlokaNumber'] as int,
      sanskritText: json['sanskritText'] as String,
      transliteration: json['transliteration'] as String?,
      xpReward: json['xpReward'] as int? ?? 2,
      chapter: json['chapter'] != null
          ? GitaChapter.fromJson(json['chapter'] as Map<String, dynamic>)
          : null,
      translations: (json['translations'] as List<dynamic>?)
              ?.map((e) => ShlokaTranslation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      audioFiles: (json['audioFiles'] as List<dynamic>?)
              ?.map((e) => ShlokaAudio.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shlokaId': shlokaId,
      'shlokaNumber': shlokaNumber,
      'sanskritText': sanskritText,
      'transliteration': transliteration,
      'xpReward': xpReward,
      'chapter': chapter?.toJson(),
      'translations': translations.map((e) => e.toJson()).toList(),
      'audioFiles': audioFiles.map((e) => e.toJson()).toList(),
    };
  }

  /// Get translation for a specific language
  ShlokaTranslation? getTranslation(String language) {
    try {
      return translations.firstWhere(
        (t) => t.language == language,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get audio for a specific language and type
  ShlokaAudio? getAudio(String language, String audioType) {
    try {
      return audioFiles.firstWhere(
        (a) => a.language == language && a.audioType == audioType,
      );
    } catch (e) {
      return null;
    }
  }
}



