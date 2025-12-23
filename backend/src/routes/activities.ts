import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/lessons/:lessonId/activities
router.get('/lessons/:lessonId/activities', async (req, res) => {
  try {
    const { lessonId } = req.params;
    
    const activities = await prisma.activity.findMany({
      where: { lessonId },
      orderBy: { displayOrder: 'asc' },
    });
    
    res.json({
      activities: activities.map(activity => ({
        activity_id: activity.activityId,
        lesson_id: activity.lessonId,
        activity_type: activity.activityType,
        content: activity.content,
        is_required: activity.isRequired,
        display_order: activity.displayOrder,
      })),
    });
  } catch (error: any) {
    console.error('Error fetching activities:', error);
    res.status(500).json({ error: 'Failed to fetch activities' });
  }
});

// POST /api/learning/activities/:activityId/submit
router.post('/:activityId/submit', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { activityId } = req.params;
    const userId = req.user!.id;
    const { submission_type, content } = req.body;
    
    // Get activity and lesson info
    const activity = await prisma.activity.findUnique({
      where: { activityId },
      include: {
        lesson: {
          include: {
            module: {
              include: {
                track: {
                  include: {
                    course: true,
                  },
                },
              },
            },
          },
        },
      },
    });
    
    if (!activity) {
      return res.status(404).json({ error: 'Activity not found' });
    }
    
    // Find enrollment
    const enrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId: activity.lesson.module.track.course.courseId,
        },
      },
    });
    
    if (!enrollment) {
      return res.status(400).json({ error: 'Not enrolled in this course' });
    }
    
    // Create submission
    const submission = await prisma.userActivitySubmission.create({
      data: {
        userId,
        activityId,
        enrollmentId: enrollment.enrollmentId,
        submissionType: submission_type || 'text',
        content,
        status: 'submitted',
      },
    });
    
    // Award karma for submission
    await prisma.userLearningMetrics.update({
      where: { userId },
      data: {
        totalKarma: { increment: 10 },
      },
    });
    
    await prisma.userXpTransaction.create({
      data: {
        userId,
        transactionType: 'karma',
        amount: 10,
        source: 'activity',
        sourceId: activityId,
        description: `Submitted ${activity.activityType} activity`,
      },
    });
    
    res.status(201).json({
      submission_id: submission.submissionId,
      activity_id: submission.activityId,
      status: submission.status,
      submitted_at: submission.submittedAt.toISOString(),
      rewards: {
        karma: 10,
      },
    });
  } catch (error: any) {
    console.error('Error submitting activity:', error);
    res.status(500).json({ error: 'Failed to submit activity' });
  }
});

// GET /api/learning/activities/submissions/me
router.get('/submissions/me', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { status, page = '1', limit = '20' } = req.query;
    
    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;
    
    const where: any = { userId };
    if (status) {
      where.status = status;
    }
    
    const [submissions, totalCount] = await Promise.all([
      prisma.userActivitySubmission.findMany({
        where,
        include: {
          activity: {
            select: {
              activityId: true,
              activityType: true,
              lesson: {
                select: {
                  lessonId: true,
                  lessonName: true,
                },
              },
            },
          },
        },
        orderBy: { submittedAt: 'desc' },
        skip,
        take: limitNum,
      }),
      prisma.userActivitySubmission.count({ where }),
    ]);
    
    res.json({
      submissions: submissions.map(sub => ({
        submission_id: sub.submissionId,
        activity_id: sub.activityId,
        activity_type: sub.activity.activityType,
        lesson_name: sub.activity.lesson.lessonName,
        status: sub.status,
        submitted_at: sub.submittedAt.toISOString(),
        reviewed_at: sub.reviewedAt?.toISOString() || null,
      })),
      pagination: {
        current_page: pageNum,
        total_pages: Math.ceil(totalCount / limitNum),
        total_items: totalCount,
      },
    });
  } catch (error: any) {
    console.error('Error fetching submissions:', error);
    res.status(500).json({ error: 'Failed to fetch submissions' });
  }
});

export default router;






