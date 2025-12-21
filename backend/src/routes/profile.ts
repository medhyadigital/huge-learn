import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import prisma from '../db/prisma';

const router = Router();

// GET /api/learning/profile/me
router.get('/me', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Check if metrics exist (acts as learning profile)
    let metrics = await prisma.userLearningMetrics.findUnique({
      where: { userId },
    });
    
    const isNew = !metrics;
    
    if (!metrics) {
      // Auto-create learning profile (metrics)
      metrics = await prisma.userLearningMetrics.create({
        data: {
          userId,
          totalXp: 0,
          totalKarma: 0,
          wisdomLevel: 1,
          currentStreak: 0,
          longestStreak: 0,
        },
      });
    }
    
    res.status(isNew ? 201 : 200).json({
      learning_profile_id: metrics.userId,
      user_id: metrics.userId,
      display_name: req.user!.name,
      preferences: {}, // Can be added as JSON field if needed
      onboarding_completed: metrics.totalLessonsCompleted > 0,
      created_at: metrics.createdAt.toISOString(),
      updated_at: metrics.updatedAt.toISOString(),
      is_new: isNew,
    });
  } catch (error: any) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// PUT /api/learning/profile/me
router.put('/me', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { preferences, onboarding_completed } = req.body;
    
    // Update metrics (representing profile)
    const metrics = await prisma.userLearningMetrics.update({
      where: { userId },
      data: {
        updatedAt: new Date(),
      },
    });
    
    res.json({
      learning_profile_id: metrics.userId,
      user_id: metrics.userId,
      preferences: preferences || {},
      onboarding_completed: onboarding_completed !== undefined ? onboarding_completed : (metrics.totalLessonsCompleted > 0),
      updated_at: metrics.updatedAt.toISOString(),
    });
  } catch (error: any) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

export default router;
