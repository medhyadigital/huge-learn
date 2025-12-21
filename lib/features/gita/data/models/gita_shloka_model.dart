import '../../domain/entities/gita_shloka.dart';
import '../../domain/entities/gita_chapter.dart';
import '../../domain/entities/shloka_translation.dart';
import '../../domain/entities/shloka_audio.dart';
import 'gita_chapter_model.dart';
import 'shloka_translation_model.dart';
import 'shloka_audio_model.dart';

/// Gita Shloka Model (Data Layer)
class GitaShlokaModel extends GitaShloka {
  const GitaShlokaModel({
    required super.shlokaId,
    required super.shlokaNumber,
    required super.sanskritText,
    super.transliteration,
    required super.xpReward,
    super.chapter,
    super.translations = const [],
    super.audioFiles = const [],
  });

  factory GitaShlokaModel.fromJson(Map<String, dynamic> json) {
    return GitaShlokaModel(
      shlokaId: json['shlokaId'] as String,
      shlokaNumber: json['shlokaNumber'] as int,
      sanskritText: json['sanskritText'] as String,
      transliteration: json['transliteration'] as String?,
      xpReward: json['xpReward'] as int? ?? 2,
      chapter: json['chapter'] != null
          ? GitaChapterModel.fromJson(json['chapter'] as Map<String, dynamic>)
          : null,
      translations: (json['translations'] as List<dynamic>?)
              ?.map((e) => ShlokaTranslationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      audioFiles: (json['audioFiles'] as List<dynamic>?)
              ?.map((e) => ShlokaAudioModel.fromJson(e as Map<String, dynamic>))
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

  GitaShloka toEntity() {
    return GitaShloka(
      shlokaId: shlokaId,
      shlokaNumber: shlokaNumber,
      sanskritText: sanskritText,
      transliteration: transliteration,
      xpReward: xpReward,
      chapter: chapter,
      translations: translations,
      audioFiles: audioFiles,
    );
  }
}

