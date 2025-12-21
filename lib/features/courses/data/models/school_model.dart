import '../../domain/entities/school.dart';

/// School model (data layer)
class SchoolModel extends School {
  const SchoolModel({
    required super.schoolId,
    required super.schoolName,
    required super.description,
    super.iconUrl,
    required super.displayOrder,
    super.courseCount,
  });
  
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      schoolId: json['school_id'] as String,
      schoolName: json['school_name'] as String,
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      courseCount: json['course_count'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'school_name': schoolName,
      'description': description,
      'icon_url': iconUrl,
      'display_order': displayOrder,
      'course_count': courseCount,
    };
  }
  
  School toEntity() {
    return School(
      schoolId: schoolId,
      schoolName: schoolName,
      description: description,
      iconUrl: iconUrl,
      displayOrder: displayOrder,
      courseCount: courseCount,
    );
  }
}




