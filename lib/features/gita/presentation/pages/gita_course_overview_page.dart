import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/gita_providers.dart';
import '../../domain/entities/gita_level.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';

/// Gita Course Overview Page - Shows all 5 levels
class GitaCourseOverviewPage extends ConsumerStatefulWidget {
  const GitaCourseOverviewPage({super.key});

  @override
  ConsumerState<GitaCourseOverviewPage> createState() => _GitaCourseOverviewPageState();
}

class _GitaCourseOverviewPageState extends ConsumerState<GitaCourseOverviewPage> {
  @override
  void initState() {
    super.initState();
    // Load levels when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevels();
    });
  }

  Future<void> _loadLevels() async {
    final useCase = ref.read(getLevelsUseCaseProvider);
    final result = await useCase();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load levels: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (levels) {
        // Levels loaded successfully
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelsFuture = ref.watch(_levelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bhagavad Gita - Living Dharma'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<GitaLevel>>(
        future: levelsFuture,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadLevels(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final levels = snapshot.data ?? [];
          if (levels.isEmpty) {
            return const Center(
              child: Text('No levels available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return _LevelCard(level: level);
            },
          );
        },
      ),
    );
  }
}

/// Provider for getting all levels
final _levelsProvider = Provider<Future<List<GitaLevel>>>((ref) async {
  final useCase = ref.watch(getLevelsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (levels) => levels,
  );
});

class _LevelCard extends StatelessWidget {
  final GitaLevel level;

  const _LevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.push('/gita/levels/${level.levelNumber}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    level.badgeIcon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${level.levelNumber}: ${level.levelName}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          level.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${level.totalChapters} Chapters',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.text_fields, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${level.totalShlokas} Shlokas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${level.xpReward} XP',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.workspace_premium, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    'Badge: ${level.badgeName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

