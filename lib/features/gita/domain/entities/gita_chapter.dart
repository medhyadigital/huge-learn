import 'package:equatable/equatable.dart';

/// Gita Chapter Entity
class GitaChapter extends Equatable {
  final int chapterId;
  final int chapterNumber;
  final String chapterName;
  final String chapterNameSanskrit;
  final String? description;
  final int totalShlokas;
  final int levelNumber;
  final int displayOrder;

  const GitaChapter({
    required this.chapterId,
    required this.chapterNumber,
    required this.chapterName,
    required this.chapterNameSanskrit,
    this.description,
    required this.totalShlokas,
    required this.levelNumber,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [
        chapterId,
        chapterNumber,
        chapterName,
        chapterNameSanskrit,
        description,
        totalShlokas,
        levelNumber,
        displayOrder,
      ];

  factory GitaChapter.fromJson(Map<String, dynamic> json) {
    return GitaChapter(
      chapterId: json['chapterId'] as int,
      chapterNumber: json['chapterNumber'] as int,
      chapterName: json['chapterName'] as String,
      chapterNameSanskrit: json['chapterNameSanskrit'] as String,
      description: json['description'] as String?,
      totalShlokas: json['totalShlokas'] as int,
      levelNumber: json['levelNumber'] as int,
      displayOrder: json['displayOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterNumber': chapterNumber,
      'chapterName': chapterName,
      'chapterNameSanskrit': chapterNameSanskrit,
      'description': description,
      'totalShlokas': totalShlokas,
      'levelNumber': levelNumber,
      'displayOrder': displayOrder,
    };
  }
}

