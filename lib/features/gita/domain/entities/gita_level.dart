import 'package:equatable/equatable.dart';
import 'gita_chapter.dart';

/// Gita Level Entity
class GitaLevel extends Equatable {
  final int levelNumber;
  final String levelName;
  final String subtitle;
  final String badgeName;
  final String badgeSlug;
  final String badgeIcon;
  final int xpReward;
  final List<GitaChapter> chapters;
  final int totalShlokas;
  final int totalChapters;

  const GitaLevel({
    required this.levelNumber,
    required this.levelName,
    required this.subtitle,
    required this.badgeName,
    required this.badgeSlug,
    required this.badgeIcon,
    required this.xpReward,
    this.chapters = const [],
    required this.totalShlokas,
    required this.totalChapters,
  });

  @override
  List<Object?> get props => [
        levelNumber,
        levelName,
        subtitle,
        badgeName,
        badgeSlug,
        badgeIcon,
        xpReward,
        chapters,
        totalShlokas,
        totalChapters,
      ];

  factory GitaLevel.fromJson(Map<String, dynamic> json) {
    return GitaLevel(
      levelNumber: json['levelNumber'] as int,
      levelName: json['levelName'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      badgeName: json['badgeName'] as String? ?? '',
      badgeSlug: json['badgeSlug'] as String? ?? '',
      badgeIcon: json['badgeIcon'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 0,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => GitaChapter.fromJson(e as Map<String, dynamic>))
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
}

