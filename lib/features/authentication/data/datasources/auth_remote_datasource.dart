import 'package:dartz/dartz.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/utils/result.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  FutureResult<UserModel> login({required String email, required String password});
  FutureResult<UserModel> register({
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
  });
  FutureResult<void> logout();
  FutureResult<void> forgotPassword({required String email});
  FutureResult<void> sendOTP({required String email, String type = 'REGISTRATION'});
  FutureResult<void> verifyOTP({required String email, required String otp, String type = 'REGISTRATION'});
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService _authService;
  final AuthLocalDataSource _localDataSource;
  
  AuthRemoteDataSourceImpl(
    this._authService,
    this._localDataSource,
  );
  
  @override
  FutureResult<UserModel> login({required String email, required String password}) async {
    final result = await _authService.login(
      email: email,
      password: password,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (authResponse) async {
        // Store user data (session-based auth, no tokens)
        final userModel = UserModel.fromJson(authResponse.user);
        await _localDataSource.cacheUser(userModel);
        
        return Right(userModel);
      },
    );
  }
  
  @override
  FutureResult<UserModel> register({
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
    final result = await _authService.register(
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
      (authResponse) async {
        // Store user data (session-based auth)
        final userModel = UserModel.fromJson(authResponse.user);
        await _localDataSource.cacheUser(userModel);
        
        return Right(userModel);
      },
    );
  }
  
  @override
  FutureResult<void> logout() async {
    return await _authService.logout();
  }
  
  @override
  FutureResult<void> forgotPassword({required String email}) async {
    return await _authService.forgotPassword(email: email);
  }
  
  @override
  FutureResult<void> sendOTP({required String email, String type = 'REGISTRATION'}) async {
    return await _authService.sendOTP(email: email, type: type);
  }
  
  @override
  FutureResult<void> verifyOTP({required String email, required String otp, String type = 'REGISTRATION'}) async {
    return await _authService.verifyOTP(email: email, otp: otp, type: type);
  }
}

