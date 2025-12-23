import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/dashboard
router.get('/', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Get all dashboard data in parallel
    const [
      metrics,
      continueEnrollment,
      recentLessons,
      badges,
      streak,
      featuredCourses,
    ] = await Promise.all([
      // User metrics
      prisma.userLearningMetrics.findUnique({ where: { userId } }),
      
      // Continue learning (last accessed enrollment)
      prisma.userCourseEnrollment.findFirst({
        where: {
          userId,
          status: { in: ['not_started', 'in_progress'] },
        },
        orderBy: { lastAccessedAt: 'desc' },
        include: {
          course: {
            select: {
              courseId: true,
              courseName: true,
              thumbnailUrl: true,
            },
          },
        },
      }),
      
      // Recent completed lessons
      prisma.userLessonProgress.findMany({
        where: {
          userId,
          status: 'completed',
        },
        orderBy: { completedAt: 'desc' },
        take: 5,
        include: {
          lesson: {
            select: {
              lessonName: true,
            },
          },
        },
      }),
      
      // Recent badges
      prisma.userBadge.findMany({
        where: { userId },
        orderBy: { earnedAt: 'desc' },
        take: 3,
        include: {
          badge: {
            select: {
              badgeName: true,
              badgeIconUrl: true,
            },
          },
        },
      }),
      
      // Today's streak
      prisma.userStreak.findUnique({
        where: {
          userId_streakDate: {
            userId,
            streakDate: new Date(new Date().setHours(0, 0, 0, 0)),
          },
        },
      }),
      
      // Featured courses
      prisma.course.findMany({
        where: {
          isFeatured: true,
          isActive: true,
        },
        take: 3,
        select: {
          courseId: true,
          courseName: true,
          shortDescription: true,
          thumbnailUrl: true,
          difficultyLevel: true,
        },
        orderBy: { displayOrder: 'asc' },
      }),
    ]);
    
    res.json({
      metrics: metrics ? {
        total_xp: metrics.totalXp,
        total_karma: metrics.totalKarma,
        wisdom_level: metrics.wisdomLevel,
        current_streak: metrics.currentStreak,
        longest_streak: metrics.longestStreak,
      } : null,
      continue_learning: continueEnrollment ? {
        enrollment_id: continueEnrollment.enrollmentId,
        course_id: continueEnrollment.course.courseId,
        course_name: continueEnrollment.course.courseName,
        thumbnail_url: continueEnrollment.course.thumbnailUrl,
        completion_percentage: parseFloat(continueEnrollment.completionPercentage.toString()),
        current_lesson_id: continueEnrollment.currentLessonId,
      } : null,
      recent_lessons: recentLessons.map(progress => ({
        lesson_name: progress.lesson.lessonName,
        completed_at: progress.completedAt?.toISOString(),
      })),
      recent_badges: badges.map(ub => ({
        badge_name: ub.badge.badgeName,
        badge_icon_url: ub.badge.badgeIconUrl,
        earned_at: ub.earnedAt.toISOString(),
      })),
      today_activity: streak ? {
        lessons_completed: streak.lessonsCompleted,
        time_spent_minutes: streak.timeSpentMinutes,
        xp_earned: streak.xpEarned,
      } : null,
      featured_courses: featuredCourses.map(course => ({
        course_id: course.courseId,
        course_name: course.courseName,
        short_description: course.shortDescription,
        thumbnail_url: course.thumbnailUrl,
        difficulty_level: course.difficultyLevel,
      })),
    });
  } catch (error: any) {
    console.error('Error fetching dashboard:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard' });
  }
});

export default router;






