import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import crypto from 'crypto';

const router = Router();

// GET /api/learning/certificates/me
router.get('/me', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    const certificates = await prisma.certificate.findMany({
      where: { userId },
      include: {
        course: {
          select: {
            courseId: true,
            courseName: true,
            thumbnailUrl: true,
          },
        },
      },
      orderBy: {
        issueDate: 'desc',
      },
    });
    
    res.json({
      certificates: certificates.map(cert => ({
        certificate_id: cert.certificateId,
        course_id: cert.courseId,
        course_name: cert.course.courseName,
        certificate_type: cert.certificateType,
        certificate_number: cert.certificateNumber,
        issue_date: cert.issueDate.toISOString().split('T')[0],
        certificate_url: cert.certificateUrl,
        verification_code: cert.verificationCode,
        is_shareable: true,
      })),
    });
  } catch (error: any) {
    console.error('Error fetching certificates:', error);
    res.status(500).json({ error: 'Failed to fetch certificates' });
  }
});

// POST /api/learning/certificates/generate
router.post('/generate', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { course_id, certificate_type = 'completion' } = req.body;
    
    if (!course_id) {
      return res.status(400).json({ error: 'course_id required' });
    }
    
    // Verify course completion
    const enrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId: course_id,
        },
      },
      include: {
        course: true,
      },
    });
    
    if (!enrollment) {
      return res.status(404).json({ error: 'Not enrolled in this course' });
    }
    
    if (enrollment.status !== 'completed') {
      return res.status(400).json({ error: 'Course not completed yet' });
    }
    
    // Check if certificate already exists
    const existing = await prisma.certificate.findFirst({
      where: {
        userId,
        courseId: course_id,
        certificateType: certificate_type,
      },
    });
    
    if (existing) {
      return res.status(400).json({ error: 'Certificate already generated' });
    }
    
    // Generate certificate number
    const certNumber = `HUG-${enrollment.course.courseSlug.substring(0, 3).toUpperCase()}-${new Date().getFullYear()}-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
    const verificationCode = crypto.randomBytes(8).toString('hex').toUpperCase();
    
    const certificate = await prisma.certificate.create({
      data: {
        userId,
        courseId: course_id,
        certificateType: certificate_type,
        certificateNumber: certNumber,
        issueDate: new Date(),
        verificationCode,
        metadata: {
          completionDate: enrollment.completedAt,
          courseName: enrollment.course.courseName,
          userName: req.user!.name,
        },
      },
    });
    
    res.status(201).json({
      certificate_id: certificate.certificateId,
      certificate_number: certificate.certificateNumber,
      verification_code: certificate.verificationCode,
      issue_date: certificate.issueDate.toISOString().split('T')[0],
      message: 'Certificate generated successfully',
    });
  } catch (error: any) {
    console.error('Error generating certificate:', error);
    res.status(500).json({ error: 'Failed to generate certificate' });
  }
});

// GET /api/learning/certificates/verify/:verificationCode
router.get('/verify/:verificationCode', async (req, res) => {
  try {
    const { verificationCode } = req.params;
    
    const certificate = await prisma.certificate.findUnique({
      where: { verificationCode },
      include: {
        course: {
          select: {
            courseName: true,
            schoolId: true,
          },
        },
      },
    });
    
    if (!certificate) {
      return res.status(404).json({ error: 'Certificate not found' });
    }
    
    res.json({
      is_valid: true,
      certificate_number: certificate.certificateNumber,
      course_name: certificate.course.courseName,
      certificate_type: certificate.certificateType,
      issue_date: certificate.issueDate.toISOString().split('T')[0],
      user_id: certificate.userId,
    });
  } catch (error: any) {
    console.error('Error verifying certificate:', error);
    res.status(500).json({ error: 'Failed to verify certificate' });
  }
});

export default router;




