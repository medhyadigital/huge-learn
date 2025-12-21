import 'package:dartz/dartz.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/learning_profile.dart';
import '../../domain/repositories/learning_profile_repository.dart';
import '../datasources/learning_profile_remote_datasource.dart';
import '../datasources/learning_profile_local_datasource.dart';

/// Implementation of LearningProfileRepository
class LearningProfileRepositoryImpl implements LearningProfileRepository {
  final LearningProfileRemoteDataSource _remoteDataSource;
  final LearningProfileLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  LearningProfileRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );
  
  @override
  FutureResult<LearningProfile> getOrCreateProfile() async {
    // Try to get from cache first (offline support)
    final cachedResult = await _localDataSource.getCachedProfile();
    
    // If offline, return cached profile
    if (!await _networkInfo.isConnected) {
      return cachedResult.fold(
        (failure) => Left(NetworkFailure('No internet connection and no cached profile')),
        (profileModel) {
          if (profileModel != null) {
            return Right(profileModel.toEntity());
          }
          return const Left(NetworkFailure('No internet connection'));
        },
      );
    }
    
    // Online: fetch from API (will auto-create if doesn't exist)
    final result = await _remoteDataSource.getOrCreateProfile();
    
    return result.fold(
      (failure) async {
        // On error, try to return cached profile as fallback
        final fallbackResult = cachedResult;
        return fallbackResult.fold(
          (cacheFailure) => Left(failure), // Return original failure
          (profileModel) {
            if (profileModel != null) {
              return Right(profileModel.toEntity());
            }
            return Left(failure);
          },
        );
      },
      (profileModel) async {
        // Cache the profile
        await _localDataSource.cacheProfile(profileModel);
        return Right(profileModel.toEntity());
      },
    );
  }
  
  @override
  FutureResult<LearningProfile> updateProfile({
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    final result = await _remoteDataSource.updateProfile(
      preferences: preferences,
      onboardingCompleted: onboardingCompleted,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (profileModel) async {
        // Update cache
        await _localDataSource.cacheProfile(profileModel);
        return Right(profileModel.toEntity());
      },
    );
  }
  
  @override
  FutureResult<LearningProfile?> getCachedProfile() async {
    final result = await _localDataSource.getCachedProfile();
    return result.fold(
      (failure) => Left(failure),
      (profileModel) => Right(profileModel?.toEntity()),
    );
  }
  
  @override
  FutureResult<void> clearProfile() async {
    return await _localDataSource.clearProfile();
  }
}

