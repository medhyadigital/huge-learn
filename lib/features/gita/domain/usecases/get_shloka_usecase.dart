import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/gita_shloka.dart';
import '../repositories/gita_repository.dart';

/// Get shloka use case
class GetShlokaUseCase {
  final GitaRepository _repository;

  GetShlokaUseCase(this._repository);

  FutureResult<GitaShloka> call(String shlokaId, {String? language}) async {
    return await _repository.getShloka(shlokaId, language: language);
  }
}



