import '../../domain/entities/gita_chapter.dart';

/// Gita Chapter Model (Data Layer)
class GitaChapterModel extends GitaChapter {
  const GitaChapterModel({
    required super.chapterId,
    required super.chapterNumber,
    required super.chapterName,
    required super.chapterNameSanskrit,
    super.description,
    required super.totalShlokas,
    required super.levelNumber,
    required super.displayOrder,
  });

  factory GitaChapterModel.fromJson(Map<String, dynamic> json) {
    return GitaChapterModel(
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

  GitaChapter toEntity() {
    return GitaChapter(
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      chapterName: chapterName,
      chapterNameSanskrit: chapterNameSanskrit,
      description: description,
      totalShlokas: totalShlokas,
      levelNumber: levelNumber,
      displayOrder: displayOrder,
    );
  }
}



