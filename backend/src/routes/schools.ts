import { Router } from 'express';
import prisma from '../db/prisma';

const router = Router();

// GET /api/learning/schools
router.get('/', async (req, res) => {
  try {
    const schools = await prisma.learningSchool.findMany({
      where: {
        isActive: true,
      },
      select: {
        schoolId: true,
        schoolName: true,
        description: true,
        iconUrl: true,
        displayOrder: true,
        _count: {
          select: { courses: true },
        },
      },
      orderBy: {
        displayOrder: 'asc',
      },
    });

    // Transform to match API contract
    const formattedSchools = schools.map((school) => ({
      school_id: school.schoolId,
      school_name: school.schoolName,
      description: school.description,
      icon_url: school.iconUrl,
      display_order: school.displayOrder,
      is_active: true,
      course_count: school._count.courses,
    }));

    res.json({
      schools: formattedSchools,
    });
  } catch (error: any) {
    console.error('Error fetching schools:', error);
    res.status(500).json({ error: 'Failed to fetch schools' });
  }
});

export default router;
