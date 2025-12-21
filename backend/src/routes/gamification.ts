import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import prisma from '../db/prisma';

const router = Router();

// GET /api/learning/gamification/metrics
router.get('/metrics', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    let metrics = await prisma.userLearningMetrics.findUnique({
      where: { userId },
    });
    
    if (!metrics) {
      // Create if doesn't exist
      metrics = await prisma.userLearningMetrics.create({
        data: {
          userId,
          totalXp: 0,
          totalKarma: 0,
          wisdomLevel: 1,
        },
      });
    }
    
    // Calculate next level XP
    const nextLevelXp = metrics.wisdomLevel * 1000;
    
    // Determine rank based on wisdom level
    let rank = 'Beginner';
    if (metrics.wisdomLevel >= 10) rank = 'Gita Sadhak';
    else if (metrics.wisdomLevel >= 20) rank = 'Karma Yogi';
    else if (metrics.wisdomLevel >= 30) rank = 'Wisdom Master';
    
    res.json({
      user_id: metrics.userId,
      total_xp: metrics.totalXp,
      total_karma: metrics.totalKarma,
      wisdom_level: metrics.wisdomLevel,
      current_streak: metrics.currentStreak,
      longest_streak: metrics.longestStreak,
      total_lessons_completed: metrics.totalLessonsCompleted,
      total_courses_completed: metrics.totalCoursesCompleted,
      total_time_spent_minutes: metrics.totalTimeSpentMinutes,
      badges_earned: 0, // Will count from user_badges
      rank,
      next_level_xp: nextLevelXp,
    });
  } catch (error: any) {
    console.error('Error fetching metrics:', error);
    res.status(500).json({ error: 'Failed to fetch metrics' });
  }
});

// GET /api/learning/gamification/badges
router.get('/badges', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Get earned badges
    const earnedBadges = await prisma.userBadge.findMany({
      where: { userId },
      include: {
        badge: true,
      },
      orderBy: {
        earnedAt: 'desc',
      },
    });
    
    // Get all badges
    const allBadges = await prisma.badge.findMany({
      where: { isActive: true },
    });
    
    const earnedBadgeIds = new Set(earnedBadges.map((ub) => ub.badgeId));
    
    // Available badges (not yet earned)
    const availableBadges = allBadges
      .filter((badge) => !earnedBadgeIds.has(badge.badgeId))
      .map((badge) => ({
        badge_id: badge.badgeId,
        badge_name: badge.badgeName,
        description: badge.description,
        badge_icon_url: badge.badgeIconUrl,
        badge_category: badge.badgeCategory,
        progress: {
          current: 0,
          required: 1,
          percentage: 0.0,
        },
      }));
    
    res.json({
      badges: earnedBadges.map((ub) => ({
        badge_id: ub.badge.badgeId,
        badge_name: ub.badge.badgeName,
        description: ub.badge.description,
        badge_icon_url: ub.badge.badgeIconUrl,
        badge_category: ub.badge.badgeCategory,
        earned_at: ub.earnedAt.toISOString(),
      })),
      available_badges: availableBadges,
    });
  } catch (error: any) {
    console.error('Error fetching badges:', error);
    res.status(500).json({ error: 'Failed to fetch badges' });
  }
});

export default router;
