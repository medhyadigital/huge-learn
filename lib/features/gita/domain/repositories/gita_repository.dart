import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/gita_chapter.dart';
import '../entities/gita_shloka.dart';
import '../entities/gita_level.dart';
import '../entities/shloka_progress.dart';

/// Gita Repository Interface
abstract class GitaRepository {
  /// Get all chapters
  FutureResult<List<GitaChapter>> getChapters();
  
  /// Get specific chapter by number
  FutureResult<GitaChapter> getChapter(int chapterNumber);
  
  /// Get shloka by ID
  FutureResult<GitaShloka> getShloka(String shlokaId, {String? language});
  
  /// Get all levels
  FutureResult<List<GitaLevel>> getLevels();
  
  /// Get specific level by number
  FutureResult<GitaLevel> getLevel(int levelNumber);
  
  /// Get user's progress
  FutureResult<Map<String, dynamic>> getProgress(String userId);
  
  /// Update shloka progress
  FutureResult<ShlokaProgress> updateProgress({
    required String userId,
    required String shlokaId,
    String? status,
    int? timeSpentSeconds,
    bool? hasListenedSanskrit,
    bool? hasListenedMeaning,
    bool? hasReadExplanation,
    String? reflection,
  });
}



