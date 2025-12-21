import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/shloka_progress.dart';
import '../repositories/gita_repository.dart';

/// Update shloka progress use case
class UpdateProgressUseCase {
  final GitaRepository _repository;

  UpdateProgressUseCase(this._repository);

  FutureResult<ShlokaProgress> call({
    required String userId,
    required String shlokaId,
    String? status,
    int? timeSpentSeconds,
    bool? hasListenedSanskrit,
    bool? hasListenedMeaning,
    bool? hasReadExplanation,
    String? reflection,
  }) async {
    return await _repository.updateProgress(
      userId: userId,
      shlokaId: shlokaId,
      status: status,
      timeSpentSeconds: timeSpentSeconds,
      hasListenedSanskrit: hasListenedSanskrit,
      hasListenedMeaning: hasListenedMeaning,
      hasReadExplanation: hasReadExplanation,
      reflection: reflection,
    );
  }
}

