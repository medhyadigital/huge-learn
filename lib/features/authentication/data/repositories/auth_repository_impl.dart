import 'package:dartz/dartz.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;
  
  @override
  FutureResult<User> login({required String email, required String password}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    final result = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (userModel) async {
        // Cache user (already cached in data source)
        return Right(userModel.toEntity());
      },
    );
  }
  
  @override
  FutureResult<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pinCode,
    required String dateOfBirth,
    required String gender,
    String? occupation,
    String? referralCode,
    String? recaptchaToken,
    String? emailOTP,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    final result = await _remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      city: city,
      state: state,
      country: country,
      pinCode: pinCode,
      dateOfBirth: dateOfBirth,
      gender: gender,
      occupation: occupation,
      referralCode: referralCode,
      recaptchaToken: recaptchaToken,
      emailOTP: emailOTP,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (userModel) async {
        // Cache user (already cached in data source)
        return Right(userModel.toEntity());
      },
    );
  }
  
  @override
  FutureResult<void> forgotPassword({required String email}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    return await _remoteDataSource.forgotPassword(email: email);
  }
  
  @override
  FutureResult<void> sendOTP({required String email, String type = 'REGISTRATION'}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    return await _remoteDataSource.sendOTP(email: email, type: type);
  }
  
  @override
  FutureResult<void> verifyOTP({required String email, required String otp, String type = 'REGISTRATION'}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    return await _remoteDataSource.verifyOTP(email: email, otp: otp, type: type);
  }
  
  @override
  FutureResult<void> refreshToken() async {
    // Session-based auth doesn't need token refresh
    // Check session instead
    return const Right(null);
  }
  
  @override
  FutureResult<void> logout() async {
    final result = await _remoteDataSource.logout();
    
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        // Clear local data
        await _localDataSource.clearAuthData();
        return const Right(null);
      },
    );
  }
  
  @override
  FutureResult<User?> getCurrentUser() async {
    // Try to get from cache first
    final cachedResult = await _localDataSource.getCachedUser();
    return cachedResult.fold(
      (failure) => Left(failure),
      (userModel) => Right(userModel?.toEntity()),
    );
  }
  
  @override
  FutureResult<bool> isAuthenticated() async {
    // Check if user is cached (session-based auth)
    final userResult = await _localDataSource.getCachedUser();
    return userResult.fold(
      (failure) => Left(failure),
      (user) => Right(user != null),
    );
  }
}

