import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/progress/me
router.get('/me', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    const enrollments = await prisma.userCourseEnrollment.findMany({
      where: { userId },
      include: {
        course: {
          select: {
            courseId: true,
            courseName: true,
            thumbnailUrl: true,
          },
        },
      },
      orderBy: {
        lastAccessedAt: 'desc',
      },
    });
    
    const formattedEnrollments = await Promise.all(
      enrollments.map(async (enrollment) => {
        const currentLesson = enrollment.currentLessonId
          ? await prisma.lesson.findUnique({
              where: { lessonId: enrollment.currentLessonId },
              select: { lessonId: true, lessonName: true },
            })
          : null;
        
        return {
          enrollment_id: enrollment.enrollmentId,
          course_id: enrollment.courseId,
          course_name: enrollment.course.courseName,
          thumbnail_url: enrollment.course.thumbnailUrl,
          completion_percentage: parseFloat(enrollment.completionPercentage.toString()),
          current_lesson: currentLesson
            ? {
                lesson_id: currentLesson.lessonId,
                lesson_name: currentLesson.lessonName,
              }
            : null,
          last_accessed_at: enrollment.lastAccessedAt.toISOString(),
          status: enrollment.status,
        };
      })
    );
    
    // Get summary metrics
    const metrics = await prisma.userLearningMetrics.findUnique({
      where: { userId },
    });
    
    res.json({
      enrollments: formattedEnrollments,
      summary: {
        total_courses_enrolled: enrollments.length,
        total_courses_completed: enrollments.filter((e) => e.status === 'completed').length,
        total_lessons_completed: metrics?.totalLessonsCompleted || 0,
        total_time_spent_minutes: metrics?.totalTimeSpentMinutes || 0,
        this_week_minutes: 0, // Can calculate from streaks
      },
    });
  } catch (error: any) {
    console.error('Error fetching progress:', error);
    res.status(500).json({ error: 'Failed to fetch progress' });
  }
});

// GET /api/learning/progress/courses/:courseId
router.get('/courses/:courseId', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user!.id;
    
    const enrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId,
        },
      },
      include: {
        course: {
          include: {
            tracks: {
              where: { isActive: true },
              include: {
                modules: {
                  where: { isActive: true },
                  include: {
                    _count: {
                      select: { lessons: true },
                    },
                  },
                  orderBy: { displayOrder: 'asc' },
                },
              },
              orderBy: { displayOrder: 'asc' },
            },
          },
        },
      },
    });
    
    if (!enrollment) {
      return res.status(404).json({ error: 'Not enrolled in this course' });
    }
    
    // Get lesson completion data for this enrollment
    const completedLessons = await prisma.userLessonProgress.findMany({
      where: {
        enrollmentId: enrollment.enrollmentId,
        status: 'completed',
      },
      orderBy: {
        completedAt: 'desc',
      },
      take: 5,
      include: {
        lesson: {
          select: {
            lessonId: true,
            lessonName: true,
          },
        },
      },
    });
    
    res.json({
      enrollment_id: enrollment.enrollmentId,
      course_id: enrollment.courseId,
      completion_percentage: parseFloat(enrollment.completionPercentage.toString()),
      tracks: enrollment.course.tracks.map((track) => ({
        track_id: track.trackId,
        track_name: track.trackName,
        is_unlocked: track.trackLevel === 'beginner',
        is_current: track.trackId === enrollment.currentTrackId,
        completion_percentage: 0, // Calculate based on lessons
        modules: track.modules.map((module) => ({
          module_id: module.moduleId,
          module_name: module.moduleName,
          completed_lessons: 0, // Calculate
          total_lessons: module._count.lessons,
          is_completed: false,
        })),
      })),
      recent_lessons: completedLessons.map((progress) => ({
        lesson_id: progress.lesson.lessonId,
        lesson_name: progress.lesson.lessonName,
        completed_at: progress.completedAt?.toISOString(),
      })),
    });
  } catch (error: any) {
    console.error('Error fetching course progress:', error);
    res.status(500).json({ error: 'Failed to fetch course progress' });
  }
});

export default router;






