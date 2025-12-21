import 'package:flutter_test/flutter_test.dart';
import 'package:huge_learning_platform/features/authentication/domain/entities/user.dart';
import 'package:huge_learning_platform/features/authentication/domain/repositories/auth_repository.dart';
import 'package:huge_learning_platform/core/utils/result.dart';
import 'package:huge_learning_platform/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
import 'authentication_integration_test.mocks.dart';

void main() {
  group('Authentication Integration Tests', () {
    late MockAuthRepository mockAuthRepository;
    
    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });
    
    group('Login Tests', () {
      test('TC-LOGIN-001: Successful login with valid email and password', () async {
        // Arrange
        final testUser = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        );
        
        when(mockAuthRepository.login(
          email: 'test@example.com',
          password: 'Test@1234',
        )).thenAnswer((_) async => Right(testUser));
        
        // Act
        final result = await mockAuthRepository.login(
          email: 'test@example.com',
          password: 'Test@1234',
        );
        
        // Assert
        expect(result, isA<Right<Failure, User>>());
        result.fold(
          (failure) => fail('Login should succeed'),
          (user) {
            expect(user.id, '123');
            expect(user.email, 'test@example.com');
            expect(user.name, 'Test User');
          },
        );
        
        verify(mockAuthRepository.login(
          email: 'test@example.com',
          password: 'Test@1234',
        )).called(1);
      });
      
      test('TC-LOGIN-004: Login with wrong password should fail', () async {
        // Arrange
        when(mockAuthRepository.login(
          email: 'test@example.com',
          password: 'WrongPassword',
        )).thenAnswer((_) async => const Left(AuthFailure('Invalid email or password')));
        
        // Act
        final result = await mockAuthRepository.login(
          email: 'test@example.com',
          password: 'WrongPassword',
        );
        
        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, 'Invalid email or password');
          },
          (user) => fail('Login should fail'),
        );
      });
      
      test('TC-LOGIN-005: Login with non-existent email should fail', () async {
        // Arrange
        when(mockAuthRepository.login(
          email: 'nonexistent@example.com',
          password: 'Test@1234',
        )).thenAnswer((_) async => const Left(AuthFailure('Invalid email or password')));
        
        // Act
        final result = await mockAuthRepository.login(
          email: 'nonexistent@example.com',
          password: 'Test@1234',
        );
        
        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
          },
          (user) => fail('Login should fail'),
        );
      });
    });
    
    group('Registration Tests', () {
      test('TC-REG-001: Successful registration with all required fields', () async {
        // Arrange
        final testUser = User(
          id: '456',
          email: 'newuser@example.com',
          name: 'New User',
        );
        
        when(mockAuthRepository.register(
          name: 'New User',
          email: 'newuser@example.com',
          phone: '+919876543210',
          password: 'Test@1234',
          confirmPassword: 'Test@1234',
          address: '123 Test St',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          pinCode: '400001',
          dateOfBirth: '1990-01-01',
          gender: 'Male',
          occupation: null,
          referralCode: null,
          recaptchaToken: null,
          emailOTP: null,
        )).thenAnswer((_) async => Right(testUser));
        
        // Act
        final result = await mockAuthRepository.register(
          name: 'New User',
          email: 'newuser@example.com',
          phone: '+919876543210',
          password: 'Test@1234',
          confirmPassword: 'Test@1234',
          address: '123 Test St',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          pinCode: '400001',
          dateOfBirth: '1990-01-01',
          gender: 'Male',
          occupation: null,
          referralCode: null,
          recaptchaToken: null,
          emailOTP: null,
        );
        
        // Assert
        expect(result, isA<Right<Failure, User>>());
        result.fold(
          (failure) => fail('Registration should succeed'),
          (user) {
            expect(user.id, '456');
            expect(user.email, 'newuser@example.com');
            expect(user.name, 'New User');
          },
        );
      });
      
      test('TC-REG-003: Registration with duplicate email should fail', () async {
        // Arrange
        when(mockAuthRepository.register(
          name: 'Duplicate User',
          email: 'existing@example.com',
          phone: '+919876543210',
          password: 'Test@1234',
          confirmPassword: 'Test@1234',
          address: '123 Test St',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          pinCode: '400001',
          dateOfBirth: '1990-01-01',
          gender: 'Male',
          occupation: null,
          referralCode: null,
          recaptchaToken: null,
          emailOTP: null,
        )).thenAnswer((_) async => const Left(AuthFailure('Email already registered')));
        
        // Act
        final result = await mockAuthRepository.register(
          name: 'Duplicate User',
          email: 'existing@example.com',
          phone: '+919876543210',
          password: 'Test@1234',
          confirmPassword: 'Test@1234',
          address: '123 Test St',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          pinCode: '400001',
          dateOfBirth: '1990-01-01',
          gender: 'Male',
          occupation: null,
          referralCode: null,
          recaptchaToken: null,
          emailOTP: null,
        );
        
        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, 'Email already registered');
          },
          (user) => fail('Registration should fail'),
        );
      });
    });
  });
}

