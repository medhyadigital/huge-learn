import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/gamification/leaderboard
router.get('/', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { type = 'xp', scope = 'global', period = 'all_time', limit = '50' } = req.query;
    
    const limitNum = Math.min(parseInt(limit as string), 100);
    
    // Determine sort field
    let orderByField: any = { totalXp: 'desc' };
    if (type === 'karma') orderByField = { totalKarma: 'desc' };
    if (type === 'streak') orderByField = { currentStreak: 'desc' };
    
    // Get top users
    const topUsers = await prisma.userLearningMetrics.findMany({
      orderBy: orderByField,
      take: limitNum,
    });
    
    // Get current user's metrics
    const currentUserMetrics = await prisma.userLearningMetrics.findUnique({
      where: { userId },
    });
    
    // Count users with better scores
    let currentUserRank = 0;
    if (currentUserMetrics) {
      const scoreField = type === 'xp' ? 'totalXp' : type === 'karma' ? 'totalKarma' : 'currentStreak';
      const userScore = currentUserMetrics[scoreField as keyof typeof currentUserMetrics] as number;
      
      currentUserRank = await prisma.userLearningMetrics.count({
        where: {
          [scoreField]: { gt: userScore },
        },
      }) + 1;
    }
    
    // Get badge counts for leaderboard users
    const userIds = topUsers.map(u => u.userId);
    const badgeCounts = await prisma.userBadge.groupBy({
      by: ['userId'],
      where: {
        userId: { in: userIds },
      },
      _count: true,
    });
    
    const badgeCountMap = new Map(
      badgeCounts.map(bc => [bc.userId, bc._count])
    );
    
    const leaderboard = topUsers.map((user, index) => ({
      rank: index + 1,
      user_id: user.userId,
      display_name: `User ${user.userId.substring(0, 8)}`, // Would fetch from HUGE Auth
      avatar_url: null,
      score: type === 'xp' ? user.totalXp : type === 'karma' ? user.totalKarma : user.currentStreak,
      badge_count: badgeCountMap.get(user.userId) || 0,
    }));
    
    res.json({
      leaderboard,
      current_user_rank: {
        rank: currentUserRank,
        score: currentUserMetrics ? (
          type === 'xp' ? currentUserMetrics.totalXp : 
          type === 'karma' ? currentUserMetrics.totalKarma : 
          currentUserMetrics.currentStreak
        ) : 0,
      },
    });
  } catch (error: any) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

export default router;



