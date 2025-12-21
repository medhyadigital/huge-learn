import '../../domain/entities/shloka_progress.dart';

/// Shloka Progress Model (Data Layer)
class ShlokaProgressModel extends ShlokaProgress {
  const ShlokaProgressModel({
    required super.progressId,
    required super.userId,
    required super.shlokaId,
    required super.status,
    required super.timeSpentSeconds,
    required super.xpEarned,
    required super.hasListenedSanskrit,
    required super.hasListenedMeaning,
    required super.hasReadExplanation,
    super.reflection,
    super.completedAt,
    required super.lastAccessedAt,
  });

  factory ShlokaProgressModel.fromJson(Map<String, dynamic> json) {
    return ShlokaProgressModel(
      progressId: json['progressId'] as String? ?? '',
      userId: json['userId'] as String,
      shlokaId: json['shlokaId'] as String,
      status: _parseStatus(json['status'] as String? ?? 'not_started'),
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      hasListenedSanskrit: json['hasListenedSanskrit'] as bool? ?? false,
      hasListenedMeaning: json['hasListenedMeaning'] as bool? ?? false,
      hasReadExplanation: json['hasReadExplanation'] as bool? ?? false,
      reflection: json['reflection'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : DateTime.now(),
    );
  }

  static ShlokaProgressStatus _parseStatus(String status) {
    switch (status) {
      case 'completed':
        return ShlokaProgressStatus.completed;
      case 'in_progress':
        return ShlokaProgressStatus.inProgress;
      default:
        return ShlokaProgressStatus.notStarted;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'progressId': progressId,
      'userId': userId,
      'shlokaId': shlokaId,
      'status': _statusToString(status),
      'timeSpentSeconds': timeSpentSeconds,
      'xpEarned': xpEarned,
      'hasListenedSanskrit': hasListenedSanskrit,
      'hasListenedMeaning': hasListenedMeaning,
      'hasReadExplanation': hasReadExplanation,
      'reflection': reflection,
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
    };
  }

  static String _statusToString(ShlokaProgressStatus status) {
    switch (status) {
      case ShlokaProgressStatus.completed:
        return 'completed';
      case ShlokaProgressStatus.inProgress:
        return 'in_progress';
      default:
        return 'not_started';
    }
  }

  ShlokaProgress toEntity() {
    return ShlokaProgress(
      progressId: progressId,
      userId: userId,
      shlokaId: shlokaId,
      status: status,
      timeSpentSeconds: timeSpentSeconds,
      xpEarned: xpEarned,
      hasListenedSanskrit: hasListenedSanskrit,
      hasListenedMeaning: hasListenedMeaning,
      hasReadExplanation: hasReadExplanation,
      reflection: reflection,
      completedAt: completedAt,
      lastAccessedAt: lastAccessedAt,
    );
  }
}

