import 'package:equatable/equatable.dart';

/// Shloka Progress Status
enum ShlokaProgressStatus {
  notStarted,
  inProgress,
  completed,
}

/// User Shloka Progress Entity
class ShlokaProgress extends Equatable {
  final String progressId;
  final String userId;
  final String shlokaId;
  final ShlokaProgressStatus status;
  final int timeSpentSeconds;
  final int xpEarned;
  final bool hasListenedSanskrit;
  final bool hasListenedMeaning;
  final bool hasReadExplanation;
  final String? reflection;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;

  const ShlokaProgress({
    required this.progressId,
    required this.userId,
    required this.shlokaId,
    required this.status,
    required this.timeSpentSeconds,
    required this.xpEarned,
    required this.hasListenedSanskrit,
    required this.hasListenedMeaning,
    required this.hasReadExplanation,
    this.reflection,
    this.completedAt,
    required this.lastAccessedAt,
  });

  @override
  List<Object?> get props => [
        progressId,
        userId,
        shlokaId,
        status,
        timeSpentSeconds,
        xpEarned,
        hasListenedSanskrit,
        hasListenedMeaning,
        hasReadExplanation,
        reflection,
        completedAt,
        lastAccessedAt,
      ];

  factory ShlokaProgress.fromJson(Map<String, dynamic> json) {
    return ShlokaProgress(
      progressId: json['progressId'] as String,
      userId: json['userId'] as String,
      shlokaId: json['shlokaId'] as String,
      status: _parseStatus(json['status'] as String),
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      hasListenedSanskrit: json['hasListenedSanskrit'] as bool? ?? false,
      hasListenedMeaning: json['hasListenedMeaning'] as bool? ?? false,
      hasReadExplanation: json['hasReadExplanation'] as bool? ?? false,
      reflection: json['reflection'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
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
}



