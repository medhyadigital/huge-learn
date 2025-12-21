import '../../domain/entities/shloka_audio.dart';

/// Shloka Audio Model (Data Layer)
class ShlokaAudioModel extends ShlokaAudio {
  const ShlokaAudioModel({
    required super.audioId,
    required super.shlokaId,
    required super.language,
    required super.audioType,
    required super.audioUrl,
    required super.durationSeconds,
    super.isOfflineAvailable = false,
  });

  factory ShlokaAudioModel.fromJson(Map<String, dynamic> json) {
    return ShlokaAudioModel(
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

  ShlokaAudio toEntity() {
    return ShlokaAudio(
      audioId: audioId,
      shlokaId: shlokaId,
      language: language,
      audioType: audioType,
      audioUrl: audioUrl,
      durationSeconds: durationSeconds,
      isOfflineAvailable: isOfflineAvailable,
    );
  }
}

