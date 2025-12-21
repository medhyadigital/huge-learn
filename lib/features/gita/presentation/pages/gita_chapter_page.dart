import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/gita_providers.dart';
import '../../domain/entities/gita_chapter.dart';
import '../../domain/entities/gita_shloka.dart';

/// Gita Chapter Page - Shows shlokas in a chapter
class GitaChapterPage extends ConsumerWidget {
  final int chapterNumber;

  const GitaChapterPage({
    super.key,
    required this.chapterNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterFuture = ref.watch(_chapterProvider(chapterNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter $chapterNumber'),
      ),
      body: FutureBuilder<GitaChapter>(
        future: chapterFuture,
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
          
          final chapter = snapshot.data!;
          
          return Column(
            children: [
              // Chapter Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.chapterName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapter.chapterNameSanskrit,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    if (chapter.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        chapter.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              // Shlokas List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapter.totalShlokas,
                  itemBuilder: (context, index) {
                    final shlokaNumber = index + 1;
                    return _ShlokaCard(
                      chapterNumber: chapterNumber,
                      shlokaNumber: shlokaNumber,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShlokaCard extends ConsumerWidget {
  final int chapterNumber;
  final int shlokaNumber;

  const _ShlokaCard({
    required this.chapterNumber,
    required this.shlokaNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('$shlokaNumber'),
        ),
        title: Text('Shloka $shlokaNumber'),
        subtitle: const Text('Tap to view'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to shloka viewer
          // For now, we'll need the shlokaId - this will be loaded from chapter data
          context.push('/gita/shlokas/$chapterNumber/$shlokaNumber');
        },
      ),
    );
  }
}

/// Provider for getting chapter by number
final _chapterProvider = Provider.family<Future<GitaChapter>, int>((ref, chapterNumber) async {
  final useCase = ref.watch(getChapterUseCaseProvider);
  final result = await useCase(chapterNumber);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (chapter) => chapter,
  );
});

