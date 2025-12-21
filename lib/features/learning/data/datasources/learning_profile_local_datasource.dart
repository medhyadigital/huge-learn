import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../models/learning_profile_model.dart';

/// Local data source for learning profiles
abstract class LearningProfileLocalDataSource {
  FutureResult<void> cacheProfile(LearningProfileModel profile);
  FutureResult<LearningProfileModel?> getCachedProfile();
  FutureResult<void> clearProfile();
}

/// Implementation of LearningProfileLocalDataSource
class LearningProfileLocalDataSourceImpl implements LearningProfileLocalDataSource {
  static const String _boxName = 'learning_profile';
  static const String _profileKey = 'current_profile';
  
  @override
  FutureResult<void> cacheProfile(LearningProfileModel profile) async {
    try {
      final box = await Hive.openBox(_boxName);
      final profileJson = jsonEncode(profile.toJson());
      await box.put(_profileKey, profileJson);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache learning profile: ${e.toString()}'));
    }
  }
  
  @override
  FutureResult<LearningProfileModel?> getCachedProfile() async {
    try {
      final box = await Hive.openBox(_boxName);
      final profileJson = box.get(_profileKey) as String?;
      
      if (profileJson == null) {
        return const Right(null);
      }
      
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      final profile = LearningProfileModel.fromJson(profileMap);
      
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached learning profile: ${e.toString()}'));
    }
  }
  
  @override
  FutureResult<void> clearProfile() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_profileKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear learning profile: ${e.toString()}'));
    }
  }
}

