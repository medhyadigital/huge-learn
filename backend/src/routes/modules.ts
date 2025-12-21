import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/modules/:moduleId
router.get('/:moduleId', async (req, res) => {
  try {
    const { moduleId } = req.params;
    
    const module = await prisma.module.findUnique({
      where: { moduleId },
      include: {
        track: {
          select: {
            trackId: true,
            trackName: true,
            course: {
              select: {
                courseId: true,
                courseName: true,
              },
            },
          },
        },
        _count: {
          select: { lessons: true },
        },
      },
    });
    
    if (!module) {
      return res.status(404).json({ error: 'Module not found' });
    }
    
    res.json({
      module_id: module.moduleId,
      track_id: module.trackId,
      module_name: module.moduleName,
      description: module.description,
      lesson_count: module._count.lessons,
      display_order: module.displayOrder,
      track: {
        track_id: module.track.trackId,
        track_name: module.track.trackName,
      },
      course: {
        course_id: module.track.course.courseId,
        course_name: module.track.course.courseName,
      },
    });
  } catch (error: any) {
    console.error('Error fetching module:', error);
    res.status(500).json({ error: 'Failed to fetch module' });
  }
});

// GET /api/learning/modules/:moduleId/lessons
router.get('/:moduleId/lessons', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { moduleId } = req.params;
    const userId = req.user!.id;
    
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
    
    // Get user progress for each lesson
    const lessonIds = lessons.map(l => l.lessonId);
    const progressRecords = await prisma.userLessonProgress.findMany({
      where: {
        userId,
        lessonId: { in: lessonIds },
      },
    });
    
    const progressMap = new Map(
      progressRecords.map(p => [p.lessonId, p])
    );
    
    const formattedLessons = lessons.map(lesson => {
      const progress = progressMap.get(lesson.lessonId);
      return {
        lesson_id: lesson.lessonId,
        lesson_name: lesson.lessonName,
        lesson_type: lesson.lessonType,
        duration_minutes: lesson.durationMinutes,
        has_quiz: lesson.hasQuiz,
        has_reflection: lesson.hasReflection,
        display_order: lesson.displayOrder,
        is_completed: progress?.status === 'completed',
        progress_percentage: progress ? parseFloat(progress.progressPercentage.toString()) : 0,
      };
    });
    
    res.json({
      lessons: formattedLessons,
    });
  } catch (error: any) {
    console.error('Error fetching lessons:', error);
    res.status(500).json({ error: 'Failed to fetch lessons' });
  }
});

export default router;



