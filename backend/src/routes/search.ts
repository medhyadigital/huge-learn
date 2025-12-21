import { Router } from 'express';
import prisma from '../db/prisma';

const router = Router();

// GET /api/learning/search
router.get('/', async (req, res) => {
  try {
    const { q, type = 'all', limit = '20' } = req.query;
    
    if (!q || typeof q !== 'string') {
      return res.status(400).json({ error: 'Search query required' });
    }
    
    const searchQuery = q.toLowerCase();
    const limitNum = Math.min(parseInt(limit as string), 50);
    
    const results: any = {
      courses: [],
      lessons: [],
      schools: [],
    };
    
    // Search courses
    if (type === 'all' || type === 'courses') {
      const courses = await prisma.course.findMany({
        where: {
          AND: [
            { isActive: true },
            {
              OR: [
                { courseName: { contains: searchQuery } },
                { shortDescription: { contains: searchQuery } },
                { courseSlug: { contains: searchQuery } },
              ],
            },
          ],
        },
        take: limitNum,
        select: {
          courseId: true,
          courseName: true,
          shortDescription: true,
          thumbnailUrl: true,
          difficultyLevel: true,
        },
      });
      
      results.courses = courses.map(course => ({
        type: 'course',
        id: course.courseId,
        title: course.courseName,
        description: course.shortDescription,
        thumbnail_url: course.thumbnailUrl,
        difficulty_level: course.difficultyLevel,
      }));
    }
    
    // Search lessons
    if (type === 'all' || type === 'lessons') {
      const lessons = await prisma.lesson.findMany({
        where: {
          AND: [
            { isActive: true },
            { lessonName: { contains: searchQuery } },
          ],
        },
        take: limitNum,
        select: {
          lessonId: true,
          lessonName: true,
          lessonType: true,
          durationMinutes: true,
          module: {
            select: {
              moduleName: true,
              track: {
                select: {
                  course: {
                    select: {
                      courseName: true,
                    },
                  },
                },
              },
            },
          },
        },
      });
      
      results.lessons = lessons.map(lesson => ({
        type: 'lesson',
        id: lesson.lessonId,
        title: lesson.lessonName,
        description: `${lesson.module.track.course.courseName} - ${lesson.module.moduleName}`,
        duration_minutes: lesson.durationMinutes,
        lesson_type: lesson.lessonType,
      }));
    }
    
    // Search schools
    if (type === 'all' || type === 'schools') {
      const schools = await prisma.learningSchool.findMany({
        where: {
          AND: [
            { isActive: true },
            {
              OR: [
                { schoolName: { contains: searchQuery } },
                { description: { contains: searchQuery } },
              ],
            },
          ],
        },
        take: limitNum,
        select: {
          schoolId: true,
          schoolName: true,
          description: true,
          iconUrl: true,
        },
      });
      
      results.schools = schools.map(school => ({
        type: 'school',
        id: school.schoolId,
        title: school.schoolName,
        description: school.description,
        icon_url: school.iconUrl,
      }));
    }
    
    const totalResults = results.courses.length + results.lessons.length + results.schools.length;
    
    res.json({
      query: q,
      total_results: totalResults,
      results,
    });
  } catch (error: any) {
    console.error('Error searching:', error);
    res.status(500).json({ error: 'Failed to search' });
  }
});

export default router;



