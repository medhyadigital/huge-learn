import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// POST /api/learning/analytics/track
router.post('/track', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { event_type, event_data } = req.body;
    
    // Store analytics event (would use dedicated analytics table or service)
    // For now, just acknowledge
    
    res.json({
      message: 'Event tracked',
      event_type,
      tracked_at: new Date().toISOString(),
    });
  } catch (error: any) {
    console.error('Error tracking analytics:', error);
    res.status(500).json({ error: 'Failed to track event' });
  }
});

// GET /api/learning/analytics/insights
router.get('/insights', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Get user insights
    const [metrics, enrollments, recentProgress] = await Promise.all([
      prisma.userLearningMetrics.findUnique({ where: { userId } }),
      prisma.userCourseEnrollment.count({ where: { userId } }),
      prisma.userLessonProgress.findMany({
        where: {
          userId,
          status: 'completed',
          completedAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
          },
        },
      }),
    ]);
    
    // Calculate insights
    const avgDailyLessons = recentProgress.length / 7;
    const estimatedCompletionDays = metrics && enrollments > 0
      ? Math.ceil((100 - parseFloat(metrics.totalLessonsCompleted.toString())) / Math.max(avgDailyLessons, 1))
      : 0;
    
    res.json({
      insights: {
        learning_pace: avgDailyLessons > 1 ? 'fast' : avgDailyLessons > 0.5 ? 'moderate' : 'slow',
        avg_daily_lessons: avgDailyLessons.toFixed(1),
        estimated_completion_days: estimatedCompletionDays,
        consistency_score: metrics?.currentStreak || 0,
        engagement_level: metrics && metrics.totalXp > 1000 ? 'high' : metrics && metrics.totalXp > 300 ? 'medium' : 'low',
      },
      recommendations: [
        avgDailyLessons < 1 ? 'Try to complete at least 1 lesson per day' : null,
        metrics && metrics.currentStreak < 7 ? 'Build a 7-day streak for consistency' : null,
      ].filter(Boolean),
    });
  } catch (error: any) {
    console.error('Error fetching insights:', error);
    res.status(500).json({ error: 'Failed to fetch insights' });
  }
});

export default router;



