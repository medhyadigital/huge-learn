import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// POST /api/learning/sync/progress
router.post('/progress', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { syncs } = req.body;
    
    if (!Array.isArray(syncs)) {
      return res.status(400).json({ error: 'syncs must be an array' });
    }
    
    let syncedCount = 0;
    let failedCount = 0;
    let totalXp = 0;
    let totalKarma = 0;
    const newBadges: string[] = [];
    
    for (const sync of syncs) {
      try {
        const { lesson_id, progress_percentage, is_completed, time_spent_seconds, completed_at } = sync;
        
        // Get lesson and enrollment
        const lesson = await prisma.lesson.findUnique({
          where: { lessonId: lesson_id },
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
          failedCount++;
          continue;
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
          failedCount++;
          continue;
        }
        
        // Update progress
        await prisma.userLessonProgress.upsert({
          where: {
            userId_lessonId: {
              userId,
              lessonId: lesson_id,
            },
          },
          update: {
            progressPercentage: progress_percentage,
            timeSpentSeconds: time_spent_seconds || 0,
            status: is_completed ? 'completed' : 'in_progress',
            completedAt: is_completed && completed_at ? new Date(completed_at) : null,
          },
          create: {
            userId,
            lessonId: lesson_id,
            enrollmentId: enrollment.enrollmentId,
            progressPercentage: progress_percentage,
            timeSpentSeconds: time_spent_seconds || 0,
            status: is_completed ? 'completed' : 'in_progress',
            completedAt: is_completed && completed_at ? new Date(completed_at) : null,
          },
        });
        
        // Award XP if completed
        if (is_completed) {
          const xp = lesson.durationMinutes * 10;
          const karma = 5;
          
          totalXp += xp;
          totalKarma += karma;
          
          await prisma.userXpTransaction.create({
            data: {
              userId,
              transactionType: 'xp',
              amount: xp,
              source: 'lesson',
              sourceId: lesson_id,
              description: `Synced completion: ${lesson.lessonName}`,
            },
          });
        }
        
        syncedCount++;
      } catch (error) {
        console.error('Error syncing progress:', error);
        failedCount++;
      }
    }
    
    // Update total metrics
    if (totalXp > 0 || totalKarma > 0) {
      await prisma.userLearningMetrics.update({
        where: { userId },
        data: {
          totalXp: { increment: totalXp },
          totalKarma: { increment: totalKarma },
          totalLessonsCompleted: { increment: syncedCount },
          lastActivityAt: new Date(),
        },
      });
    }
    
    res.json({
      synced_count: syncedCount,
      failed_count: failedCount,
      rewards: {
        total_xp: totalXp,
        total_karma: totalKarma,
        new_badges: newBadges,
      },
    });
  } catch (error: any) {
    console.error('Error syncing progress:', error);
    res.status(500).json({ error: 'Failed to sync progress' });
  }
});

// GET /api/learning/sync/status
router.get('/status', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Get last sync time
    const lastProgress = await prisma.userLessonProgress.findFirst({
      where: { userId },
      orderBy: { lastAccessedAt: 'desc' },
    });
    
    res.json({
      last_sync_at: lastProgress?.lastAccessedAt.toISOString() || null,
      pending_syncs: 0, // Would check for local unsync'd data
      is_syncing: false,
    });
  } catch (error: any) {
    console.error('Error fetching sync status:', error);
    res.status(500).json({ error: 'Failed to fetch sync status' });
  }
});

export default router;



