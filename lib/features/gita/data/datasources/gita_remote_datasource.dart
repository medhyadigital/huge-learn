import '../../../../core/network/api_client.dart';
import '../models/gita_chapter_model.dart';
import '../models/gita_shloka_model.dart';
import '../models/gita_level_model.dart';
import '../models/shloka_progress_model.dart';

/// Gita Remote Data Source
abstract class GitaRemoteDataSource {
  Future<List<GitaChapterModel>> getChapters();
  Future<GitaChapterModel> getChapter(int chapterNumber);
  Future<GitaShlokaModel> getShloka(String shlokaId, {String? language});
  Future<List<GitaLevelModel>> getLevels();
  Future<GitaLevelModel> getLevel(int levelNumber);
  Future<ShlokaProgressModel> getProgress(String userId);
  Future<ShlokaProgressModel> updateProgress({
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

class GitaRemoteDataSourceImpl implements GitaRemoteDataSource {
  final ApiClient _apiClient;

  GitaRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<GitaChapterModel>> getChapters() async {
    final response = await _apiClient.get('/chapters');
    final data = response.data as Map<String, dynamic>;
    final chapters = (data['data'] as List<dynamic>)
        .map((json) => GitaChapterModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return chapters;
  }

  @override
  Future<GitaChapterModel> getChapter(int chapterNumber) async {
    final response = await _apiClient.get('/chapters/$chapterNumber');
    final data = response.data as Map<String, dynamic>;
    return GitaChapterModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<GitaShlokaModel> getShloka(String shlokaId, {String? language}) async {
    final queryParams = language != null ? {'language': language} : null;
    final response = await _apiClient.get(
      '/shlokas/$shlokaId',
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    return GitaShlokaModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<GitaLevelModel>> getLevels() async {
    final response = await _apiClient.get('/levels');
    final data = response.data as Map<String, dynamic>;
    final levels = (data['data'] as List<dynamic>)
        .map((json) => GitaLevelModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return levels;
  }

  @override
  Future<GitaLevelModel> getLevel(int levelNumber) async {
    final response = await _apiClient.get('/levels/$levelNumber');
    final data = response.data as Map<String, dynamic>;
    return GitaLevelModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ShlokaProgressModel> getProgress(String userId) async {
    final response = await _apiClient.get('/progress/$userId');
    final data = response.data as Map<String, dynamic>;
    // Progress endpoint returns stats and progress list
    // For now, return a placeholder - will need to handle the actual response structure
    return ShlokaProgressModel.fromJson({
      'userId': userId,
      'shlokaId': '',
      'status': 'not_started',
      'timeSpentSeconds': 0,
      'xpEarned': 0,
      'hasListenedSanskrit': false,
      'hasListenedMeaning': false,
      'hasReadExplanation': false,
      'lastAccessedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<ShlokaProgressModel> updateProgress({
    required String userId,
    required String shlokaId,
    String? status,
    int? timeSpentSeconds,
    bool? hasListenedSanskrit,
    bool? hasListenedMeaning,
    bool? hasReadExplanation,
    String? reflection,
  }) async {
    final response = await _apiClient.post(
      '/progress',
      data: {
        'userId': userId,
        'shlokaId': shlokaId,
        if (status != null) 'status': status,
        if (timeSpentSeconds != null) 'timeSpentSeconds': timeSpentSeconds,
        if (hasListenedSanskrit != null) 'hasListenedSanskrit': hasListenedSanskrit,
        if (hasListenedMeaning != null) 'hasListenedMeaning': hasListenedMeaning,
        if (hasReadExplanation != null) 'hasReadExplanation': hasReadExplanation,
        if (reflection != null) 'reflection': reflection,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return ShlokaProgressModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}

