import 'package:equatable/equatable.dart';

/// Shloka Audio Entity
class ShlokaAudio extends Equatable {
  final String audioId;
  final String shlokaId;
  final String language; // 'en', 'hi', 'sa'
  final String audioType; // 'sanskrit', 'meaning'
  final String audioUrl;
  final int durationSeconds;
  final bool isOfflineAvailable;

  const ShlokaAudio({
    required this.audioId,
    required this.shlokaId,
    required this.language,
    required this.audioType,
    required this.audioUrl,
    required this.durationSeconds,
    this.isOfflineAvailable = false,
  });

  @override
  List<Object?> get props => [
        audioId,
        shlokaId,
        language,
        audioType,
        audioUrl,
        durationSeconds,
        isOfflineAvailable,
      ];

  factory ShlokaAudio.fromJson(Map<String, dynamic> json) {
    return ShlokaAudio(
      audioId: json['audioId'] as String,
      shlokaId: json['shlokaId'] as String,
      language: json['language'] as String,
      audioType: json['audioType'] as String,
      audioUrl: json['audioUrl'] as String,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'shlokaId': shlokaId,
      'language': language,
      'audioType': audioType,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'isOfflineAvailable': isOfflineAvailable,
    };
  }
}



