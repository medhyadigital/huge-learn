import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/modules/:moduleId/lessons
router.get('/modules/:moduleId/lessons', async (req, res) => {
  try {
    const { moduleId } = req.params;
    
    const lessons = await prisma.lesson.findMany({
      where: {
        moduleId,
        isActive: true,
      },
      select: {
        lessonId: true,
        lessonName: true,
        lessonType: true,
        durationMinutes: true,
        hasQuiz: true,
        hasReflection: true,
        displayOrder: true,
      },
      orderBy: {
        displayOrder: 'asc',
      },
    });
    
    res.json({
      lessons: lessons.map((lesson) => ({
        lesson_id: lesson.lessonId,
        lesson_name: lesson.lessonName,
        lesson_type: lesson.lessonType,
        duration_minutes: lesson.durationMinutes,
        has_quiz: lesson.hasQuiz,
        has_reflection: lesson.hasReflection,
        display_order: lesson.displayOrder,
        is_completed: false, // Will check user progress
        progress_percentage: 0.0,
      })),
    });
  } catch (error: any) {
    console.error('Error fetching lessons:', error);
    res.status(500).json({ error: 'Failed to fetch lessons' });
  }
});

// GET /api/learning/lessons/:lessonId
router.get('/:lessonId', async (req, res) => {
  try {
    const { lessonId } = req.params;
    
    const lesson = await prisma.lesson.findUnique({
      where: { lessonId },
    });
    
    if (!lesson) {
      return res.status(404).json({ error: 'Lesson not found' });
    }
    
    // Find next and previous lessons
    const [nextLesson, prevLesson] = await Promise.all([
      prisma.lesson.findFirst({
        where: {
          moduleId: lesson.moduleId,
          displayOrder: { gt: lesson.displayOrder },
          isActive: true,
        },
        orderBy: { displayOrder: 'asc' },
        select: { lessonId: true },
      }),
      prisma.lesson.findFirst({
        where: {
          moduleId: lesson.moduleId,
          displayOrder: { lt: lesson.displayOrder },
          isActive: true,
        },
        orderBy: { displayOrder: 'desc' },
        select: { lessonId: true },
      }),
    ]);
    
    res.json({
      lesson_id: lesson.lessonId,
      lesson_name: lesson.lessonName,
      lesson_type: lesson.lessonType,
      content: lesson.content,
      duration_minutes: lesson.durationMinutes,
      has_quiz: lesson.hasQuiz,
      has_reflection: lesson.hasReflection,
      user_progress: {
        status: 'not_started',
        progress_percentage: 0.0,
        last_slide_index: 0,
        time_spent_seconds: 0,
      },
      next_lesson_id: nextLesson?.lessonId || null,
      previous_lesson_id: prevLesson?.lessonId || null,
    });
  } catch (error: any) {
    console.error('Error fetching lesson:', error);
    res.status(500).json({ error: 'Failed to fetch lesson' });
  }
});

// POST /api/learning/lessons/:lessonId/progress
router.post('/:lessonId/progress', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { lessonId } = req.params;
    const userId = req.user!.id;
    const { progress_percentage, completed_slide_index, time_spent_seconds } = req.body;
    
    // Find enrollment
    const lesson = await prisma.lesson.findUnique({
      where: { lessonId },
      include: {
        module: {
          include: {
            track: {
              include: {
                course: true,
              },
            },
          },
        },
      },
    });
    
    if (!lesson) {
      return res.status(404).json({ error: 'Lesson not found' });
    }
    
    const enrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId: lesson.module.track.course.courseId,
        },
      },
    });
    
    if (!enrollment) {
      return res.status(400).json({ error: 'Not enrolled in this course' });
    }
    
    // Update or create progress
    const progress = await prisma.userLessonProgress.upsert({
      where: {
        userId_lessonId: {
          userId,
          lessonId,
        },
      },
      update: {
        progressPercentage: progress_percentage,
        timeSpentSeconds: time_spent_seconds || 0,
        completionData: { lastSlideIndex: completed_slide_index },
        status: progress_percentage >= 100 ? 'completed' : 'in_progress',
        completedAt: progress_percentage >= 100 ? new Date() : null,
      },
      create: {
        userId,
        lessonId,
        enrollmentId: enrollment.enrollmentId,
        progressPercentage: progress_percentage,
        timeSpentSeconds: time_spent_seconds || 0,
        completionData: { lastSlideIndex: completed_slide_index },
        status: progress_percentage >= 100 ? 'completed' : 'in_progress',
        completedAt: progress_percentage >= 100 ? new Date() : null,
      },
    });
    
    res.json({
      progress_id: progress.progressId,
      lesson_id: progress.lessonId,
      progress_percentage: parseFloat(progress.progressPercentage.toString()),
      status: progress.status,
      xp_earned: progress_percentage >= 100 ? 50 : 10,
    });
  } catch (error: any) {
    console.error('Error updating progress:', error);
    res.status(500).json({ error: 'Failed to update progress' });
  }
});

// POST /api/learning/lessons/:lessonId/complete
router.post('/:lessonId/complete', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { lessonId } = req.params;
    const userId = req.user!.id;
    
    // Get lesson and enrollment
    const lesson = await prisma.lesson.findUnique({
      where: { lessonId },
      include: {
        module: {
          include: {
            track: {
              include: {
                course: true,
              },
            },
          },
        },
      },
    });
    
    if (!lesson) {
      return res.status(404).json({ error: 'Lesson not found' });
    }
    
    const enrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId: lesson.module.track.course.courseId,
        },
      },
    });
    
    if (!enrollment) {
      return res.status(400).json({ error: 'Not enrolled in this course' });
    }
    
    // Mark lesson as completed
    const progress = await prisma.userLessonProgress.upsert({
      where: {
        userId_lessonId: {
          userId,
          lessonId,
        },
      },
      update: {
        status: 'completed',
        progressPercentage: 100,
        completedAt: new Date(),
      },
      create: {
        userId,
        lessonId,
        enrollmentId: enrollment.enrollmentId,
        status: 'completed',
        progressPercentage: 100,
        completedAt: new Date(),
      },
    });
    
    // Award XP
    const xpEarned = lesson.durationMinutes * 10;
    const karmaEarned = 5;
    
    await prisma.userLearningMetrics.update({
      where: { userId },
      data: {
        totalXp: { increment: xpEarned },
        totalKarma: { increment: karmaEarned },
        totalLessonsCompleted: { increment: 1 },
        totalTimeSpentMinutes: { increment: lesson.durationMinutes },
        lastActivityAt: new Date(),
      },
    });
    
    // Record XP transaction
    await prisma.userXpTransaction.create({
      data: {
        userId,
        transactionType: 'xp',
        amount: xpEarned,
        source: 'lesson',
        sourceId: lessonId,
        description: `Completed lesson: ${lesson.lessonName}`,
      },
    });
    
    // Update streak
    await updateStreak(userId);
    
    // Check for badge eligibility
    const newBadges = await checkBadgeEligibility(userId);
    
    // Find next lesson
    const nextLesson = await prisma.lesson.findFirst({
      where: {
        moduleId: lesson.moduleId,
        displayOrder: { gt: lesson.displayOrder },
        isActive: true,
      },
      orderBy: { displayOrder: 'asc' },
      select: { lessonId: true },
    });
    
    res.json({
      progress_id: progress.progressId,
      lesson_id: progress.lessonId,
      status: 'completed',
      completed_at: progress.completedAt?.toISOString(),
      rewards: {
        xp: xpEarned,
        karma: karmaEarned,
        badges: newBadges,
        next_lesson_unlocked: !!nextLesson,
      },
      next_lesson_id: nextLesson?.lessonId || null,
    });
  } catch (error: any) {
    console.error('Error completing lesson:', error);
    res.status(500).json({ error: 'Failed to complete lesson' });
  }
});

// Helper: Update user streak
async function updateStreak(userId: string) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  // Check if already logged activity today
  const todayStreak = await prisma.userStreak.findUnique({
    where: {
      userId_streakDate: {
        userId,
        streakDate: today,
      },
    },
  });
  
  if (!todayStreak) {
    // Create today's streak
    await prisma.userStreak.create({
      data: {
        userId,
        streakDate: today,
        lessonsCompleted: 1,
        xpEarned: 10,
      },
    });
    
    // Update metrics
    const metrics = await prisma.userLearningMetrics.findUnique({
      where: { userId },
    });
    
    if (metrics) {
      // Check yesterday
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      
      const yesterdayStreak = await prisma.userStreak.findUnique({
        where: {
          userId_streakDate: {
            userId,
            streakDate: yesterday,
          },
        },
      });
      
      if (yesterdayStreak) {
        // Continue streak
        await prisma.userLearningMetrics.update({
          where: { userId },
          data: {
            currentStreak: { increment: 1 },
            longestStreak: Math.max(metrics.currentStreak + 1, metrics.longestStreak),
          },
        });
      } else {
        // Reset streak
        await prisma.userLearningMetrics.update({
          where: { userId },
          data: {
            currentStreak: 1,
          },
        });
      }
    }
  } else {
    // Update today's streak
    await prisma.userStreak.update({
      where: {
        userId_streakDate: {
          userId,
          streakDate: today,
        },
      },
      data: {
        lessonsCompleted: { increment: 1 },
        xpEarned: { increment: 10 },
      },
    });
  }
}

// Helper: Check badge eligibility
async function checkBadgeEligibility(userId: string): Promise<string[]> {
  const newBadges: string[] = [];
  
  const metrics = await prisma.userLearningMetrics.findUnique({
    where: { userId },
  });
  
  if (!metrics) return newBadges;
  
  // Check "First Lesson" badge
  if (metrics.totalLessonsCompleted === 1) {
    const badge = await prisma.badge.findUnique({
      where: { badgeSlug: 'first-lesson' },
    });
    
    if (badge) {
      await prisma.userBadge.create({
        data: {
          userId,
          badgeId: badge.badgeId,
          context: { lessonsCompleted: 1 },
        },
      }).catch(() => {}); // Ignore if already awarded
      
      newBadges.push(badge.badgeSlug);
    }
  }
  
  return newBadges;
}

export default router;



