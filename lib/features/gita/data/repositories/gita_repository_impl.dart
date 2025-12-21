import 'package:dartz/dartz.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/gita_repository.dart';
import '../../domain/entities/gita_chapter.dart';
import '../../domain/entities/gita_shloka.dart';
import '../../domain/entities/gita_level.dart';
import '../../domain/entities/shloka_progress.dart';
import '../datasources/gita_remote_datasource.dart';
import '../models/gita_chapter_model.dart';
import '../models/gita_shloka_model.dart';
import '../models/gita_level_model.dart';
import '../models/shloka_progress_model.dart';

/// Gita Repository Implementation
class GitaRepositoryImpl implements GitaRepository {
  final GitaRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  GitaRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  FutureResult<List<GitaChapter>> getChapters() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final chapters = await _remoteDataSource.getChapters();
      return Right(chapters.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureResult<GitaChapter> getChapter(int chapterNumber) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final chapter = await _remoteDataSource.getChapter(chapterNumber);
      return Right(chapter.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureResult<GitaShloka> getShloka(String shlokaId, {String? language}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final shloka = await _remoteDataSource.getShloka(shlokaId, language: language);
      return Right(shloka.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureResult<List<GitaLevel>> getLevels() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final levels = await _remoteDataSource.getLevels();
      return Right(levels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureResult<GitaLevel> getLevel(int levelNumber) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final level = await _remoteDataSource.getLevel(levelNumber);
      return Right(level.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureResult<Map<String, dynamic>> getProgress(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      // Note: This will need to be updated based on actual API response structure
      final progress = await _remoteDataSource.getProgress(userId);
      return Right({
        'stats': {
          'totalShlokas': 700,
          'completed': 0,
          'inProgress': 0,
          'notStarted': 700,
          'totalXpEarned': 0,
        },
        'progress': [progress.toEntity()],
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureResult<ShlokaProgress> updateProgress({
    required String userId,
    required String shlokaId,
    String? status,
    int? timeSpentSeconds,
    bool? hasListenedSanskrit,
    bool? hasListenedMeaning,
    bool? hasReadExplanation,
    String? reflection,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final progress = await _remoteDataSource.updateProgress(
        userId: userId,
        shlokaId: shlokaId,
        status: status,
        timeSpentSeconds: timeSpentSeconds,
        hasListenedSanskrit: hasListenedSanskrit,
        hasListenedMeaning: hasListenedMeaning,
        hasReadExplanation: hasReadExplanation,
        reflection: reflection,
      );
      return Right(progress.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

