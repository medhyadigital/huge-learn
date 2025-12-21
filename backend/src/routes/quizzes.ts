import { Router } from 'express';
import prisma from '../db/prisma';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/learning/quizzes/:quizId
router.get('/:quizId', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { quizId } = req.params;
    const userId = req.user!.id;
    
    const quiz = await prisma.quiz.findUnique({
      where: { quizId },
    });
    
    if (!quiz) {
      return res.status(404).json({ error: 'Quiz not found' });
    }
    
    // Get user's previous attempts
    const attempts = await prisma.userQuizAttempt.findMany({
      where: {
        userId,
        quizId,
      },
      orderBy: {
        attemptedAt: 'desc',
      },
    });
    
    const bestScore = attempts.length > 0
      ? Math.max(...attempts.map((a) => parseFloat(a.score.toString())))
      : 0;
    
    res.json({
      quiz_id: quiz.quizId,
      lesson_id: quiz.lessonId,
      quiz_name: quiz.quizName,
      quiz_type: quiz.quizType,
      passing_score: quiz.passingScore,
      max_attempts: quiz.maxAttempts,
      time_limit_minutes: quiz.timeLimitMinutes,
      questions: quiz.questions,
      user_attempts: {
        attempts_taken: attempts.length,
        best_score: bestScore,
        last_attempt_at: attempts[0]?.attemptedAt.toISOString() || null,
      },
    });
  } catch (error: any) {
    console.error('Error fetching quiz:', error);
    res.status(500).json({ error: 'Failed to fetch quiz' });
  }
});

// POST /api/learning/quizzes/:quizId/submit
router.post('/:quizId/submit', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { quizId } = req.params;
    const userId = req.user!.id;
    const { answers, time_taken_seconds } = req.body;
    
    const quiz = await prisma.quiz.findUnique({
      where: { quizId },
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
    
    if (!quiz) {
      return res.status(404).json({ error: 'Quiz not found' });
    }
    
    // Get enrollment
    const enrollment = await prisma.userCourseEnrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId: quiz.lesson.module.track.course.courseId,
        },
      },
    });
    
    if (!enrollment) {
      return res.status(400).json({ error: 'Not enrolled in this course' });
    }
    
    // Calculate score
    const questions = quiz.questions as any[];
    let correctCount = 0;
    const results: any[] = [];
    
    questions.forEach((question) => {
      const userAnswer = answers.find((a: any) => a.question_id === question.questionId);
      const isCorrect = userAnswer?.selected_option === question.correctAnswer;
      
      if (isCorrect) correctCount++;
      
      results.push({
        question_id: question.questionId,
        is_correct: isCorrect,
        selected_option: userAnswer?.selected_option,
        correct_option: question.correctAnswer,
        explanation: question.explanation,
      });
    });
    
    const score = (correctCount / questions.length) * 100;
    const passed = score >= quiz.passingScore;
    
    // Get attempt number
    const previousAttempts = await prisma.userQuizAttempt.count({
      where: {
        userId,
        quizId,
      },
    });
    
    // Save attempt
    const attempt = await prisma.userQuizAttempt.create({
      data: {
        userId,
        quizId,
        enrollmentId: enrollment.enrollmentId,
        attemptNumber: previousAttempts + 1,
        answers,
        score,
        passed,
        timeTakenSeconds: time_taken_seconds || 0,
      },
    });
    
    // Award XP if passed
    if (passed) {
      const xpEarned = 100;
      const karmaEarned = 20;
      
      await prisma.userLearningMetrics.update({
        where: { userId },
        data: {
          totalXp: { increment: xpEarned },
          totalKarma: { increment: karmaEarned },
        },
      });
      
      await prisma.userXpTransaction.create({
        data: {
          userId,
          transactionType: 'xp',
          amount: xpEarned,
          source: 'quiz',
          sourceId: quizId,
          description: `Passed quiz: ${quiz.quizName}`,
        },
      });
    }
    
    res.json({
      attempt_id: attempt.attemptId,
      score: parseFloat(attempt.score.toString()),
      passed: attempt.passed,
      correct_answers: correctCount,
      total_questions: questions.length,
      time_taken_seconds: attempt.timeTakenSeconds,
      rewards: passed ? {
        xp: 100,
        karma: 20,
      } : null,
      results,
    });
  } catch (error: any) {
    console.error('Error submitting quiz:', error);
    res.status(500).json({ error: 'Failed to submit quiz' });
  }
});

export default router;



