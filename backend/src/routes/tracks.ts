import { Router } from 'express';
import prisma from '../db/prisma';

const router = Router();

// GET /api/learning/tracks/:trackId/modules
router.get('/:trackId/modules', async (req, res) => {
  try {
    const { trackId } = req.params;
    
    const modules = await prisma.module.findMany({
      where: {
        trackId,
        isActive: true,
      },
      include: {
        _count: {
          select: { lessons: true },
        },
      },
      orderBy: {
        displayOrder: 'asc',
      },
    });
    
    res.json({
      modules: modules.map((module) => ({
        module_id: module.moduleId,
        module_name: module.moduleName,
        description: module.description,
        lesson_count: module._count.lessons,
        display_order: module.displayOrder,
        user_progress: {
          completed_lessons: 0,
          total_lessons: module._count.lessons,
          is_completed: false,
        },
      })),
    });
  } catch (error: any) {
    console.error('Error fetching modules:', error);
    res.status(500).json({ error: 'Failed to fetch modules' });
  }
});

export default router;




