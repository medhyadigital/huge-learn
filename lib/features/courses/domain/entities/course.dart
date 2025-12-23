import 'package:equatable/equatable.dart';

/// Course difficulty level
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

/// Course entity
class Course extends Equatable {
  final String courseId;
  final String schoolId;
  final String courseName;
  final String courseSlug;
  final String shortDescription;
  final String? longDescription;
  final String? thumbnailUrl;
  final String? bannerUrl;
  final int durationDays;
  final DifficultyLevel difficultyLevel;
  final int totalLessons;
  final double estimatedHours;
  final bool isFeatured;
  final bool isActive;
  
  const Course({
    required this.courseId,
    required this.schoolId,
    required this.courseName,
    required this.courseSlug,
    required this.shortDescription,
    this.longDescription,
    this.thumbnailUrl,
    this.bannerUrl,
    this.durationDays = 30,
    this.difficultyLevel = DifficultyLevel.beginner,
    this.totalLessons = 0,
    this.estimatedHours = 0.0,
    this.isFeatured = false,
    this.isActive = true,
  });
  
  @override
  List<Object?> get props => [
    courseId,
    schoolId,
    courseName,
    courseSlug,
    shortDescription,
    longDescription,
    thumbnailUrl,
    bannerUrl,
    durationDays,
    difficultyLevel,
    totalLessons,
    estimatedHours,
    isFeatured,
    isActive,
  ];
}






