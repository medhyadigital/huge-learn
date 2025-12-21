import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

/**
 * GET /api/gita/chapters
 * Get all chapters with their level information
 */
router.get('/chapters', async (req: Request, res: Response) => {
  try {
    const chapters = await prisma.gitaChapter.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: 'asc' },
      include: {
        _count: {
          select: { shlokas: true },
        },
      },
    });

    res.json({
      success: true,
      data: chapters.map((ch) => ({
        chapterId: ch.chapterId,
        chapterNumber: ch.chapterNumber,
        chapterName: ch.chapterName,
        chapterNameSanskrit: ch.chapterNameSanskrit,
        description: ch.description,
        totalShlokas: ch.totalShlokas,
        levelNumber: ch.levelNumber,
        displayOrder: ch.displayOrder,
      })),
    });
  } catch (error: any) {
    console.error('Error fetching chapters:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch chapters',
      message: error.message,
    });
  }
});

/**
 * GET /api/gita/chapters/:chapterNumber
 * Get specific chapter with all shlokas
 */
router.get('/chapters/:chapterNumber', async (req: Request, res: Response) => {
  try {
    const chapterNumber = parseInt(req.params.chapterNumber);
    
    const chapter = await prisma.gitaChapter.findUnique({
      where: { chapterNumber },
      include: {
        shlokas: {
          where: { isActive: true },
          orderBy: { displayOrder: 'asc' },
          select: {
            shlokaId: true,
            shlokaNumber: true,
            sanskritText: true,
            transliteration: true,
            xpReward: true,
          },
        },
      },
    });

    if (!chapter) {
      return res.status(404).json({
        success: false,
        error: 'Chapter not found',
      });
    }

    res.json({
      success: true,
      data: chapter,
    });
  } catch (error: any) {
    console.error('Error fetching chapter:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch chapter',
      message: error.message,
    });
  }
});

/**
 * GET /api/gita/shlokas/:shlokaId
 * Get specific shloka with translations and audio
 */
router.get('/shlokas/:shlokaId', async (req: Request, res: Response) => {
  try {
    const { shlokaId } = req.params;
    const language = (req.query.language as string) || 'en';

    const shloka = await prisma.gitaShloka.findUnique({
      where: { shlokaId },
      include: {
        chapter: {
          select: {
            chapterId: true,
            chapterNumber: true,
            chapterName: true,
            chapterNameSanskrit: true,
            levelNumber: true,
          },
        },
        translations: {
          where: {
            language: language,
            isActive: true,
          },
        },
        audioFiles: {
          where: {
            language: language,
            isActive: true,
          },
        },
      },
    });

    if (!shloka) {
      return res.status(404).json({
        success: false,
        error: 'Shloka not found',
      });
    }

    res.json({
      success: true,
      data: shloka,
    });
  } catch (error: any) {
    console.error('Error fetching shloka:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch shloka',
      message: error.message,
    });
  }
});

/**
 * GET /api/gita/levels
 * Get all levels with their chapters
 */
router.get('/levels', async (req: Request, res: Response) => {
  try {
    const levels = [1, 2, 3, 4, 5];
    const levelData = [];

    for (const levelNum of levels) {
      const chapters = await prisma.gitaChapter.findMany({
        where: {
          levelNumber: levelNum,
          isActive: true,
        },
        orderBy: { displayOrder: 'asc' },
        include: {
          _count: {
            select: { shlokas: true },
          },
        },
      });

      const totalShlokas = chapters.reduce(
        (sum, ch) => sum + (ch.totalShlokas || 0),
        0
      );

      levelData.push({
        levelNumber: levelNum,
        chapters: chapters.map((ch) => ({
          chapterId: ch.chapterId,
          chapterNumber: ch.chapterNumber,
          chapterName: ch.chapterName,
          chapterNameSanskrit: ch.chapterNameSanskrit,
          totalShlokas: ch.totalShlokas,
        })),
        totalShlokas,
        totalChapters: chapters.length,
      });
    }

    res.json({
      success: true,
      data: levelData,
    });
  } catch (error: any) {
    console.error('Error fetching levels:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch levels',
      message: error.message,
    });
  }
});

/**
 * GET /api/gita/levels/:levelNumber
 * Get specific level with all chapters and shlokas
 */
router.get('/levels/:levelNumber', async (req: Request, res: Response) => {
  try {
    const levelNumber = parseInt(req.params.levelNumber);

    const chapters = await prisma.gitaChapter.findMany({
      where: {
        levelNumber,
        isActive: true,
      },
      orderBy: { displayOrder: 'asc' },
      include: {
        shlokas: {
          where: { isActive: true },
          orderBy: { displayOrder: 'asc' },
          select: {
            shlokaId: true,
            shlokaNumber: true,
            sanskritText: true,
            transliteration: true,
            xpReward: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: {
        levelNumber,
        chapters,
      },
    });
  } catch (error: any) {
    console.error('Error fetching level:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch level',
      message: error.message,
    });
  }
});

/**
 * GET /api/gita/progress/:userId
 * Get user's progress across all shlokas
 */
router.get('/progress/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    const progress = await prisma.userShlokaProgress.findMany({
      where: { userId },
      include: {
        shloka: {
          include: {
            chapter: {
              select: {
                chapterNumber: true,
                chapterName: true,
                levelNumber: true,
              },
            },
          },
        },
      },
      orderBy: { lastAccessedAt: 'desc' },
    });

    const stats = {
      totalShlokas: 700,
      completed: progress.filter((p) => p.status === 'completed').length,
      inProgress: progress.filter((p) => p.status === 'in_progress').length,
      notStarted: 700 - progress.length,
      totalXpEarned: progress.reduce((sum, p) => sum + p.xpEarned, 0),
    };

    res.json({
      success: true,
      data: {
        stats,
        progress,
      },
    });
  } catch (error: any) {
    console.error('Error fetching progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch progress',
      message: error.message,
    });
  }
});

/**
 * POST /api/gita/progress
 * Update user's shloka progress
 */
router.post('/progress', async (req: Request, res: Response) => {
  try {
    const { userId, shlokaId, status, timeSpentSeconds, hasListenedSanskrit, hasListenedMeaning, hasReadExplanation, reflection } = req.body;

    if (!userId || !shlokaId) {
      return res.status(400).json({
        success: false,
        error: 'userId and shlokaId are required',
      });
    }

    const shloka = await prisma.gitaShloka.findUnique({
      where: { shlokaId },
    });

    if (!shloka) {
      return res.status(404).json({
        success: false,
        error: 'Shloka not found',
      });
    }

    // Calculate XP based on completion
    let xpEarned = 0;
    if (status === 'completed') {
      xpEarned = shloka.xpReward;
    }

    const progress = await prisma.userShlokaProgress.upsert({
      where: {
        userId_shlokaId: {
          userId,
          shlokaId,
        },
      },
      update: {
        status: status || undefined,
        timeSpentSeconds: timeSpentSeconds || undefined,
        hasListenedSanskrit: hasListenedSanskrit !== undefined ? hasListenedSanskrit : undefined,
        hasListenedMeaning: hasListenedMeaning !== undefined ? hasListenedMeaning : undefined,
        hasReadExplanation: hasReadExplanation !== undefined ? hasReadExplanation : undefined,
        reflection: reflection || undefined,
        xpEarned: xpEarned || undefined,
        completedAt: status === 'completed' ? new Date() : undefined,
      },
      create: {
        userId,
        shlokaId,
        status: status || 'not_started',
        timeSpentSeconds: timeSpentSeconds || 0,
        hasListenedSanskrit: hasListenedSanskrit || false,
        hasListenedMeaning: hasListenedMeaning || false,
        hasReadExplanation: hasReadExplanation || false,
        reflection: reflection || null,
        xpEarned,
        completedAt: status === 'completed' ? new Date() : null,
      },
    });

    res.json({
      success: true,
      data: progress,
    });
  } catch (error: any) {
    console.error('Error updating progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update progress',
      message: error.message,
    });
  }
});

export default router;

