import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/gita_chapter.dart';
import '../repositories/gita_repository.dart';

/// Get all chapters use case
class GetChaptersUseCase {
  final GitaRepository _repository;

  GetChaptersUseCase(this._repository);

  FutureResult<List<GitaChapter>> call() async {
    return await _repository.getChapters();
  }
}

