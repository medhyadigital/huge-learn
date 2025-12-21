import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/gita_chapter.dart';
import '../repositories/gita_repository.dart';

/// Get specific chapter use case
class GetChapterUseCase {
  final GitaRepository _repository;

  GetChapterUseCase(this._repository);

  FutureResult<GitaChapter> call(int chapterNumber) async {
    return await _repository.getChapter(chapterNumber);
  }
}

