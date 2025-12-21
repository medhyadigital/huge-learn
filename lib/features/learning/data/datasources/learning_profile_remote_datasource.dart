import 'package:dartz/dartz.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../models/learning_profile_model.dart';

/// Remote data source for learning profiles
abstract class LearningProfileRemoteDataSource {
  /// Get or auto-create learning profile for current user
  FutureResult<LearningProfileModel> getOrCreateProfile();
  
  /// Update learning profile
  FutureResult<LearningProfileModel> updateProfile({
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
  });
}

/// Implementation of LearningProfileRemoteDataSource
class LearningProfileRemoteDataSourceImpl implements LearningProfileRemoteDataSource {
  final ApiClient _apiClient;
  
  LearningProfileRemoteDataSourceImpl(this._apiClient);
  
  @override
  FutureResult<LearningProfileModel> getOrCreateProfile() async {
    try {
      final response = await _apiClient.get('/profile/me');
      
      final profileModel = LearningProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      
      return Right(profileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get learning profile: ${e.toString()}'));
    }
  }
  
  @override
  FutureResult<LearningProfileModel> updateProfile({
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (preferences != null) data['preferences'] = preferences;
      if (onboardingCompleted != null) data['onboarding_completed'] = onboardingCompleted;
      
      final response = await _apiClient.put(
        '/profile/me',
        data: data,
      );
      
      final profileModel = LearningProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      
      return Right(profileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to update learning profile: ${e.toString()}'));
    }
  }
}

