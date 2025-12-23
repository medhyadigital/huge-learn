import '../../domain/entities/gita_level.dart';
import '../../domain/entities/gita_chapter.dart';
import 'gita_chapter_model.dart';

/// Gita Level Model (Data Layer)
class GitaLevelModel extends GitaLevel {
  const GitaLevelModel({
    required super.levelNumber,
    required super.levelName,
    required super.subtitle,
    required super.badgeName,
    required super.badgeSlug,
    required super.badgeIcon,
    required super.xpReward,
    super.chapters = const [],
    required super.totalShlokas,
    required super.totalChapters,
  });

  factory GitaLevelModel.fromJson(Map<String, dynamic> json) {
    return GitaLevelModel(
      levelNumber: json['levelNumber'] as int,
      levelName: json['levelName'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      badgeName: json['badgeName'] as String? ?? '',
      badgeSlug: json['badgeSlug'] as String? ?? '',
      badgeIcon: json['badgeIcon'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 0,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => GitaChapterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalShlokas: json['totalShlokas'] as int? ?? 0,
      totalChapters: json['totalChapters'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'levelName': levelName,
      'subtitle': subtitle,
      'badgeName': badgeName,
      'badgeSlug': badgeSlug,
      'badgeIcon': badgeIcon,
      'xpReward': xpReward,
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'totalShlokas': totalShlokas,
      'totalChapters': totalChapters,
    };
  }

  GitaLevel toEntity() {
    return GitaLevel(
      levelNumber: levelNumber,
      levelName: levelName,
      subtitle: subtitle,
      badgeName: badgeName,
      badgeSlug: badgeSlug,
      badgeIcon: badgeIcon,
      xpReward: xpReward,
      chapters: chapters,
      totalShlokas: totalShlokas,
      totalChapters: totalChapters,
    );
  }
}



