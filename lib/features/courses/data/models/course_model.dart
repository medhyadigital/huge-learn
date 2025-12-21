import '../../domain/entities/course.dart';

/// Course model (data layer)
class CourseModel extends Course {
  const CourseModel({
    required super.courseId,
    required super.schoolId,
    required super.courseName,
    required super.courseSlug,
    required super.shortDescription,
    super.longDescription,
    super.thumbnailUrl,
    super.bannerUrl,
    super.durationDays,
    super.difficultyLevel,
    super.totalLessons,
    super.estimatedHours,
    super.isFeatured,
    super.isActive,
  });
  
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['course_id'] as String,
      schoolId: json['school_id'] as String,
      courseName: json['course_name'] as String,
      courseSlug: json['course_slug'] as String,
      shortDescription: json['short_description'] as String? ?? '',
      longDescription: json['long_description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      durationDays: json['duration_days'] as int? ?? 30,
      difficultyLevel: _parseDifficultyLevel(json['difficulty_level'] as String?),
      totalLessons: json['total_lessons'] as int? ?? 0,
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble() ?? 0.0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'school_id': schoolId,
      'course_name': courseName,
      'course_slug': courseSlug,
      'short_description': shortDescription,
      'long_description': longDescription,
      'thumbnail_url': thumbnailUrl,
      'banner_url': bannerUrl,
      'duration_days': durationDays,
      'difficulty_level': difficultyLevel.name,
      'total_lessons': totalLessons,
      'estimated_hours': estimatedHours,
      'is_featured': isFeatured,
      'is_active': isActive,
    };
  }
  
  Course toEntity() {
    return Course(
      courseId: courseId,
      schoolId: schoolId,
      courseName: courseName,
      courseSlug: courseSlug,
      shortDescription: shortDescription,
      longDescription: longDescription,
      thumbnailUrl: thumbnailUrl,
      bannerUrl: bannerUrl,
      durationDays: durationDays,
      difficultyLevel: difficultyLevel,
      totalLessons: totalLessons,
      estimatedHours: estimatedHours,
      isFeatured: isFeatured,
      isActive: isActive,
    );
  }
  
  static DifficultyLevel _parseDifficultyLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }
}




