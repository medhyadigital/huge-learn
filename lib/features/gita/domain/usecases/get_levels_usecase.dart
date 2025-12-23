import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/gita_level.dart';
import '../repositories/gita_repository.dart';

/// Get all levels use case
class GetLevelsUseCase {
  final GitaRepository _repository;

  GetLevelsUseCase(this._repository);

  FutureResult<List<GitaLevel>> call() async {
    return await _repository.getLevels();
  }
}



