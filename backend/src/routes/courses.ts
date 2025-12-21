import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/schools/:schoolId/courses
router.get('/schools/:schoolId/courses', async (req, res) => {
  try {
    const { schoolId } = req.params;
    const { page = '1', limit = '20', level, featured } = req.query;
    
    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;
    
    const where: any = {
      schoolId,
      isActive: true,
    };
    
    if (level) {
      where.difficultyLevel = level;
    }
    
    if (featured === 'true') {
      where.isFeatured = true;
    }
    
    const [courses, totalCount] = await Promise.all([
      prisma.course.findMany({
        where,
        select: {
          courseId: true,
          courseName: true,
          courseSlug: true,
          shortDescription: true,
          thumbnailUrl: true,
          difficultyLevel: true,
          durationDays: true,
          totalLessons: true,
          estimatedHours: true,
          isFeatured: true,
        },
        orderBy: [
          { isFeatured: 'desc' },
          { displayOrder: 'asc' },
        ],
        skip,
        take: limitNum,
      }),
      prisma.course.count({ where }),
    ]);
    
    const formattedCourses = courses.map((course) => ({
      course_id: course.courseId,
      course_name: course.courseName,
      course_slug: course.courseSlug,
      short_description: course.shortDescription,
      thumbnail_url: course.thumbnailUrl,
      difficulty_level: course.difficultyLevel,
      duration_days: course.durationDays,
      total_lessons: course.totalLessons,
      estimated_hours: parseFloat(course.estimatedHours.toString()),
      is_featured: course.isFeatured,
      enrollment_status: 'not_enrolled', // Will check user enrollment later
    }));
    
    res.json({
      courses: formattedCourses,
      pagination: {
        current_page: pageNum,
        total_pages: Math.ceil(totalCount / limitNum),
        total_items: totalCount,
      },
    });
  } catch (error: any) {
    console.error('Error fetching courses:', error);
    res.status(500).json({ error: 'Failed to fetch courses' });
  }
});

// GET /api/learning/courses/:courseId
router.get('/:courseId', async (req, res) => {
  try {
    const { courseId } = req.params;
    
    const course = await prisma.course.findUnique({
      where: { courseId },
      include: {
        school: {
          select: {
            schoolId: true,
            schoolName: true,
          },
        },
        tracks: {
          where: { isActive: true },
          include: {
            _count: {
              select: {
                modules: true,
              },
            },
          },
          orderBy: {
            displayOrder: 'asc',
          },
        },
      },
    });
    
    if (!course) {
      return res.status(404).json({ error: 'Course not found' });
    }
    
    // Count lessons in each track
    const tracksWithLessonCount = await Promise.all(
      course.tracks.map(async (track) => {
        const lessonCount = await prisma.lesson.count({
          where: {
            module: {
              trackId: track.trackId,
            },
            isActive: true,
          },
        });
        
        return {
          track_id: track.trackId,
          track_name: track.trackName,
          track_level: track.trackLevel,
          description: track.description,
          module_count: track._count.modules,
          lesson_count: lessonCount,
          is_unlocked: track.trackLevel === 'beginner', // First track always unlocked
        };
      })
    );
    
    res.json({
      course_id: course.courseId,
      school_id: course.schoolId,
      course_name: course.courseName,
      course_slug: course.courseSlug,
      short_description: course.shortDescription,
      long_description: course.longDescription,
      thumbnail_url: course.thumbnailUrl,
      banner_url: course.bannerUrl,
      difficulty_level: course.difficultyLevel,
      duration_days: course.durationDays,
      total_lessons: course.totalLessons,
      estimated_hours: parseFloat(course.estimatedHours.toString()),
      tracks: tracksWithLessonCount,
      user_progress: null, // Will add when user auth is implemented
    });
  } catch (error: any) {
    console.error('Error fetching course:', error);
    res.status(500).json({ error: 'Failed to fetch course' });
  }
});

// POST /api/learning/courses/:courseId/enroll
router.post('/:courseId/enroll', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user!.id;
    
    // Check if course exists
    const course = await prisma.course.findUnique({
      where: { courseId },
      include: {
        tracks: {
          where: { isActive: true },
          orderBy: { displayOrder: 'asc' },
          take: 1,
        },
      },
    });
    
    if (!course) {
      return res.status(404).json({ error: 'Course not found' });
    }
    
    // Check if already enrolled
    const existingEnrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId,
        },
      },
    });
    
    if (existingEnrollment) {
      return res.status(400).json({ error: 'Already enrolled in this course' });
    }
    
    // Get first lesson of first track
    const firstModule = await prisma.module.findFirst({
      where: {
        trackId: course.tracks[0]?.trackId,
        isActive: true,
      },
      orderBy: { displayOrder: 'asc' },
      include: {
        lessons: {
          where: { isActive: true },
          orderBy: { displayOrder: 'asc' },
          take: 1,
        },
      },
    });
    
    // Create enrollment
    const enrollment = await prisma.userCourseEnrollment.create({
      data: {
        userId,
        courseId,
        currentTrackId: course.tracks[0]?.trackId,
        currentLessonId: firstModule?.lessons[0]?.lessonId,
        status: 'not_started',
      },
    });
    
    // Initialize user metrics if not exists
    await prisma.userLearningMetrics.upsert({
      where: { userId },
      update: {},
      create: {
        userId,
        totalXp: 0,
        totalKarma: 0,
        wisdomLevel: 1,
      },
    });
    
    res.status(201).json({
      enrollment_id: enrollment.enrollmentId,
      course_id: enrollment.courseId,
      user_id: enrollment.userId,
      enrolled_at: enrollment.enrolledAt.toISOString(),
      first_lesson_id: enrollment.currentLessonId,
    });
  } catch (error: any) {
    console.error('Error enrolling in course:', error);
    res.status(500).json({ error: 'Failed to enroll in course' });
  }
});

export default router;
