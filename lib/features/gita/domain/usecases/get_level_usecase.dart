import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/gita_level.dart';
import '../repositories/gita_repository.dart';

/// Get specific level use case
class GetLevelUseCase {
  final GitaRepository _repository;

  GetLevelUseCase(this._repository);

  FutureResult<GitaLevel> call(int levelNumber) async {
    return await _repository.getLevel(levelNumber);
  }
}

