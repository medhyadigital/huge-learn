import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/gita_providers.dart';
import '../../domain/entities/gita_shloka.dart';
import '../../domain/entities/shloka_audio.dart';
import '../widgets/audio_player_widget.dart';

/// Shloka Viewer Page - Displays shloka with Sanskrit, translation, and audio
class ShlokaViewerPage extends ConsumerStatefulWidget {
  final String shlokaId;
  final String? language;

  const ShlokaViewerPage({
    super.key,
    required this.shlokaId,
    this.language,
  });

  @override
  ConsumerState<ShlokaViewerPage> createState() => _ShlokaViewerPageState();
}

class _ShlokaViewerPageState extends ConsumerState<ShlokaViewerPage> {
  final AudioPlayer _sanskritPlayer = AudioPlayer();
  final AudioPlayer _meaningPlayer = AudioPlayer();
  bool _hasListenedSanskrit = false;
  bool _hasListenedMeaning = false;
  bool _hasReadExplanation = false;
  String? _reflection;

  @override
  void dispose() {
    _sanskritPlayer.dispose();
    _meaningPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSanskritAudio(ShlokaAudio? audio) async {
    if (audio == null) return;
    
    try {
      await _sanskritPlayer.setUrl(audio.audioUrl);
      await _sanskritPlayer.play();
      setState(() {
        _hasListenedSanskrit = true;
      });
      _updateProgress(hasListenedSanskrit: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _playMeaningAudio(ShlokaAudio? audio) async {
    if (audio == null) return;
    
    try {
      await _meaningPlayer.setUrl(audio.audioUrl);
      await _meaningPlayer.play();
      setState(() {
        _hasListenedMeaning = true;
      });
      _updateProgress(hasListenedMeaning: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _updateProgress({
    bool? hasListenedSanskrit,
    bool? hasListenedMeaning,
    bool? hasReadExplanation,
  }) async {
    // Get current user ID from auth
    // For now, using placeholder
    final userId = 'current_user_id'; // TODO: Get from auth provider
    
    final useCase = ref.read(updateProgressUseCaseProvider);
    await useCase(
      userId: userId,
      shlokaId: widget.shlokaId,
      hasListenedSanskrit: hasListenedSanskrit,
      hasListenedMeaning: hasListenedMeaning,
      hasReadExplanation: hasReadExplanation,
    );
  }

  Future<void> _markAsComplete() async {
    final userId = 'current_user_id'; // TODO: Get from auth provider
    
    final useCase = ref.read(updateProgressUseCaseProvider);
    final result = await useCase(
      userId: userId,
      shlokaId: widget.shlokaId,
      status: 'completed',
    );
    
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update progress: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (progress) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shloka marked as complete! +2 XP'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = widget.language ?? 'en';
    final shlokaFuture = ref.watch(_shlokaProvider(widget.shlokaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shloka'),
      ),
      body: FutureBuilder<GitaShloka>(
        future: shlokaFuture,
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
          
          final shloka = snapshot.data!;
          final translation = shloka.getTranslation(language);
          final sanskritAudio = shloka.getAudio('sa', 'sanskrit');
          final meaningAudio = shloka.getAudio(language, 'meaning');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sanskrit Text
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Sanskrit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (sanskritAudio != null)
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () => _playSanskritAudio(sanskritAudio),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          shloka.sanskritText,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        if (shloka.transliteration != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            shloka.transliteration!,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if (sanskritAudio != null) ...[
                          const SizedBox(height: 8),
                          AudioPlayerWidget(
                            player: _sanskritPlayer,
                            audio: sanskritAudio,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Translation
                if (translation != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Meaning (${language.toUpperCase()})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (meaningAudio != null)
                                IconButton(
                                  icon: const Icon(Icons.play_circle_outline),
                                  onPressed: () => _playMeaningAudio(meaningAudio),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            translation.meaning,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          if (meaningAudio != null) ...[
                            const SizedBox(height: 8),
                            AudioPlayerWidget(
                              player: _meaningPlayer,
                              audio: meaningAudio,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Explanation
                if (translation?.explanation != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Explanation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            translation!.explanation!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Why It Matters
                if (translation?.whyItMatters != null)
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Why This Matters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            translation!.whyItMatters!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Complete Button
                ElevatedButton.icon(
                  onPressed: _markAsComplete,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Complete (+2 XP)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Provider for getting shloka by ID
final _shlokaProvider = Provider.family<Future<GitaShloka>, String>(
  (ref, shlokaId) async {
    final useCase = ref.watch(getShlokaUseCaseProvider);
    final result = await useCase(shlokaId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (shloka) => shloka,
    );
  },
);

