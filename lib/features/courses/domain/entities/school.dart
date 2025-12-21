import 'package:equatable/equatable.dart';

/// Learning School entity
class School extends Equatable {
  final String schoolId;
  final String schoolName;
  final String description;
  final String? iconUrl;
  final int displayOrder;
  final int? courseCount;
  
  const School({
    required this.schoolId,
    required this.schoolName,
    required this.description,
    this.iconUrl,
    required this.displayOrder,
    this.courseCount,
  });
  
  @override
  List<Object?> get props => [
    schoolId,
    schoolName,
    description,
    iconUrl,
    displayOrder,
    courseCount,
  ];
}



