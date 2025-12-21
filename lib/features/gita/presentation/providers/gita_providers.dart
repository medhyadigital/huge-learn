import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/gita_remote_datasource.dart';
import '../../data/repositories/gita_repository_impl.dart';
import '../../domain/repositories/gita_repository.dart';
import '../../domain/usecases/get_chapters_usecase.dart';
import '../../domain/usecases/get_chapter_usecase.dart';
import '../../domain/usecases/get_shloka_usecase.dart';
import '../../domain/usecases/get_levels_usecase.dart';
import '../../domain/usecases/get_level_usecase.dart';
import '../../domain/usecases/update_progress_usecase.dart';

/// Gita Remote Data Source Provider
final gitaRemoteDataSourceProvider = Provider<GitaRemoteDataSource>((ref) {
  final apiClient = ref.watch(gitaApiClientProvider);
  return GitaRemoteDataSourceImpl(apiClient);
});

/// Connectivity Provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfo(connectivity);
});

/// Gita Repository Provider
final gitaRepositoryProvider = Provider<GitaRepository>((ref) {
  final remoteDataSource = ref.watch(gitaRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return GitaRepositoryImpl(remoteDataSource, networkInfo);
});

/// Use Cases Providers
final getChaptersUseCaseProvider = Provider<GetChaptersUseCase>((ref) {
  final repository = ref.watch(gitaRepositoryProvider);
  return GetChaptersUseCase(repository);
});

final getChapterUseCaseProvider = Provider<GetChapterUseCase>((ref) {
  final repository = ref.watch(gitaRepositoryProvider);
  return GetChapterUseCase(repository);
});

final getShlokaUseCaseProvider = Provider<GetShlokaUseCase>((ref) {
  final repository = ref.watch(gitaRepositoryProvider);
  return GetShlokaUseCase(repository);
});

final getLevelsUseCaseProvider = Provider<GetLevelsUseCase>((ref) {
  final repository = ref.watch(gitaRepositoryProvider);
  return GetLevelsUseCase(repository);
});

final getLevelUseCaseProvider = Provider<GetLevelUseCase>((ref) {
  final repository = ref.watch(gitaRepositoryProvider);
  return GetLevelUseCase(repository);
});

final updateProgressUseCaseProvider = Provider<UpdateProgressUseCase>((ref) {
  final repository = ref.watch(gitaRepositoryProvider);
  return UpdateProgressUseCase(repository);
});

