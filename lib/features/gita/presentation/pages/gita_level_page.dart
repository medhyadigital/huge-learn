import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/gita_providers.dart';
import '../../domain/entities/gita_level.dart';
import '../../domain/entities/gita_chapter.dart';

/// Gita Level Page - Shows chapters in a level
class GitaLevelPage extends ConsumerWidget {
  final int levelNumber;

  const GitaLevelPage({
    super.key,
    required this.levelNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelFuture = ref.watch(_levelProvider(levelNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text('Level $levelNumber'),
      ),
      body: FutureBuilder<GitaLevel>(
        future: levelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }
          
          final level = snapshot.data!;
          if (level.chapters.isEmpty) {
            return const Center(
              child: Text('No chapters available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: level.chapters.length,
            itemBuilder: (context, index) {
              final chapter = level.chapters[index];
              return _ChapterCard(chapter: chapter);
            },
          );
        },
      ),
    );
  }
}

/// Provider for getting level by number
final _levelProvider = Provider.family<Future<GitaLevel>, int>((ref, levelNumber) async {
  final useCase = ref.watch(getLevelUseCaseProvider);
  final result = await useCase(levelNumber);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (level) => level,
  );
});

class _ChapterCard extends StatelessWidget {
  final GitaChapter chapter;

  const _ChapterCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/gita/chapters/${chapter.chapterNumber}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${chapter.chapterNumber}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.chapterName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapter.chapterNameSanskrit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chapter.totalShlokas} Shlokas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}


