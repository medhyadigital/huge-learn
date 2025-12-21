import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/ai/recommendations
router.get('/recommendations', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Get or generate recommendations
    let recommendations = await prisma.aiRecommendation.findMany({
      where: {
        userId,
        isShown: false,
        OR: [
          { expiresAt: null },
          { expiresAt: { gt: new Date() } },
        ],
      },
      orderBy: {
        priority: 'desc',
      },
      take: 5,
    });
    
    // If no recommendations, generate based on user activity
    if (recommendations.length === 0) {
      recommendations = await generateRecommendations(userId);
    }
    
    // Mark as shown
    if (recommendations.length > 0) {
      await prisma.aiRecommendation.updateMany({
        where: {
          recommendationId: {
            in: recommendations.map(r => r.recommendationId),
          },
        },
        data: {
          isShown: true,
        },
      });
    }
    
    res.json({
      recommendations: recommendations.map(rec => ({
        recommendation_id: rec.recommendationId,
        type: rec.recommendationType,
        title: getRecommendationTitle(rec.recommendationType),
        description: rec.reason || getRecommendationDescription(rec.recommendationType),
        target_id: rec.targetId,
        priority: rec.priority,
        action_text: getActionText(rec.recommendationType),
        action_url: getActionUrl(rec.recommendationType, rec.targetId),
      })),
    });
  } catch (error: any) {
    console.error('Error fetching recommendations:', error);
    res.status(500).json({ error: 'Failed to fetch recommendations' });
  }
});

// POST /api/learning/ai/recommendations/:recommendationId/act
router.post('/recommendations/:recommendationId/act', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { recommendationId } = req.params;
    const userId = req.user!.id;
    
    await prisma.aiRecommendation.update({
      where: { recommendationId },
      data: {
        isActedUpon: true,
      },
    });
    
    res.json({
      message: 'Recommendation marked as acted upon',
    });
  } catch (error: any) {
    console.error('Error marking recommendation:', error);
    res.status(500).json({ error: 'Failed to mark recommendation' });
  }
});

// Helper: Generate recommendations based on user activity
async function generateRecommendations(userId: string) {
  const metrics = await prisma.userLearningMetrics.findUnique({
    where: { userId },
  });
  
  if (!metrics) return [];
  
  const newRecommendations = [];
  
  // Recommendation 1: If completed a course, suggest next level
  const completedEnrollments = await prisma.userCourseEnrollment.findMany({
    where: {
      userId,
      status: 'completed',
    },
    include: {
      course: true,
    },
    orderBy: {
      completedAt: 'desc',
    },
    take: 1,
  });
  
  if (completedEnrollments.length > 0) {
    const lastCourse = completedEnrollments[0].course;
    
    // Find next level course in same school
    const nextCourse = await prisma.course.findFirst({
      where: {
        schoolId: lastCourse.schoolId,
        difficultyLevel: 'intermediate',
        isActive: true,
        courseId: { not: lastCourse.courseId },
      },
    });
    
    if (nextCourse) {
      const rec = await prisma.aiRecommendation.create({
        data: {
          userId,
          recommendationType: 'next_course',
          targetId: nextCourse.courseId,
          priority: 90,
          reason: `You completed ${lastCourse.courseName}. Ready for the next level?`,
          context: { completedCourseId: lastCourse.courseId },
        },
      });
      newRecommendations.push(rec);
    }
  }
  
  // Recommendation 2: Encourage streak if current streak > 0
  if (metrics.currentStreak > 0 && metrics.currentStreak < 7) {
    const rec = await prisma.aiRecommendation.create({
      data: {
        userId,
        recommendationType: 'badge',
        priority: 70,
        reason: `You're on a ${metrics.currentStreak} day streak! Keep going to reach 7 days.`,
        context: { currentStreak: metrics.currentStreak },
      },
    });
    newRecommendations.push(rec);
  }
  
  return newRecommendations;
}

// Helper functions
function getRecommendationTitle(type: string): string {
  const titles: Record<string, string> = {
    next_course: 'Try This Course Next',
    weak_topic: 'Review This Topic',
    group: 'Join a Learning Group',
    seva: 'Apply Your Learning',
    badge: 'Earn Your Next Badge',
  };
  return titles[type] || 'Recommendation';
}

function getRecommendationDescription(type: string): string {
  const descriptions: Record<string, string> = {
    next_course: 'Based on your progress, this course is perfect for you',
    weak_topic: 'Strengthen your understanding',
    group: 'Connect with fellow learners',
    seva: 'Put your knowledge into action',
    badge: 'You\'re close to earning this achievement',
  };
  return descriptions[type] || '';
}

function getActionText(type: string): string {
  const actions: Record<string, string> = {
    next_course: 'Start Course',
    weak_topic: 'Review Now',
    group: 'Join Group',
    seva: 'Explore Opportunities',
    badge: 'View Badge',
  };
  return actions[type] || 'View';
}

function getActionUrl(type: string, targetId: string | null): string {
  if (!targetId) return '/';
  
  const urls: Record<string, string> = {
    next_course: `/courses/${targetId}`,
    weak_topic: `/lessons/${targetId}`,
    group: `/groups/${targetId}`,
    seva: `/seva`,
    badge: `/badges/${targetId}`,
  };
  return urls[type] || '/';
}

export default router;




