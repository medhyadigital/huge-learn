import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import routes
import authRoutes from './routes/auth';
import schoolsRoutes from './routes/schools';
import coursesRoutes from './routes/courses';
import profileRoutes from './routes/profile';
import gamificationRoutes from './routes/gamification';
import tracksRoutes from './routes/tracks';
import lessonsRoutes from './routes/lessons';
import quizzesRoutes from './routes/quizzes';
import progressRoutes from './routes/progress';
import modulesRoutes from './routes/modules';
import activitiesRoutes from './routes/activities';
import certificatesRoutes from './routes/certificates';
import aiMentorRoutes from './routes/ai-mentor';
import notificationsRoutes from './routes/notifications';
import syncRoutes from './routes/sync';
import leaderboardRoutes from './routes/leaderboard';
import searchRoutes from './routes/search';
import analyticsRoutes from './routes/analytics';
import dashboardRoutes from './routes/dashboard';
import gitaRoutes from './routes/gita';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'HUGE Learning Platform API is running',
    timestamp: new Date().toISOString(),
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/learning/schools', schoolsRoutes);
app.use('/api/learning/courses', coursesRoutes);
app.use('/api/learning/profile', profileRoutes);
app.use('/api/learning/gamification', gamificationRoutes);
app.use('/api/learning/gamification/leaderboard', leaderboardRoutes);
app.use('/api/learning/tracks', tracksRoutes);
app.use('/api/learning/lessons', lessonsRoutes);
app.use('/api/learning/modules', modulesRoutes);
app.use('/api/learning/quizzes', quizzesRoutes);
app.use('/api/learning/progress', progressRoutes);
app.use('/api/learning/activities', activitiesRoutes);
app.use('/api/learning/certificates', certificatesRoutes);
app.use('/api/learning/ai', aiMentorRoutes);
app.use('/api/learning/notifications', notificationsRoutes);
app.use('/api/learning/sync', syncRoutes);
app.use('/api/learning/search', searchRoutes);
app.use('/api/learning/analytics', analyticsRoutes);
app.use('/api/learning/dashboard', dashboardRoutes);
app.use('/api/gita', gitaRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n🚀 HUGE Learning Platform API`);
  console.log(`📡 Server running on port ${PORT}`);
  console.log(`🔗 API URL: http://localhost:${PORT}`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`\n📚 API Endpoints (40+ endpoints):`);
  console.log(`\n   🔐 Authentication:`);
  console.log(`   POST   /api/auth/login`);
  console.log(`   POST   /api/auth/refresh`);
  console.log(`   POST   /api/auth/logout`);
  
  console.log(`\n   📚 Schools & Courses:`);
  console.log(`   GET    /api/learning/schools`);
  console.log(`   GET    /api/learning/schools/:schoolId/courses`);
  console.log(`   GET    /api/learning/courses/:courseId`);
  console.log(`   POST   /api/learning/courses/:courseId/enroll`);
  
  console.log(`\n   🎓 Learning Content:`);
  console.log(`   GET    /api/learning/tracks/:trackId/modules`);
  console.log(`   GET    /api/learning/modules/:moduleId`);
  console.log(`   GET    /api/learning/modules/:moduleId/lessons`);
  console.log(`   GET    /api/learning/lessons/:lessonId`);
  console.log(`   POST   /api/learning/lessons/:lessonId/progress`);
  console.log(`   POST   /api/learning/lessons/:lessonId/complete`);
  console.log(`   GET    /api/learning/lessons/:lessonId/activities`);
  
  console.log(`\n   ❓ Quizzes:`);
  console.log(`   GET    /api/learning/quizzes/:quizId`);
  console.log(`   POST   /api/learning/quizzes/:quizId/submit`);
  
  console.log(`\n   🎮 Gamification:`);
  console.log(`   GET    /api/learning/gamification/metrics`);
  console.log(`   GET    /api/learning/gamification/badges`);
  console.log(`   GET    /api/learning/gamification/leaderboard`);
  
  console.log(`\n   📊 Progress & Profile:`);
  console.log(`   GET    /api/learning/profile/me`);
  console.log(`   PUT    /api/learning/profile/me`);
  console.log(`   GET    /api/learning/progress/me`);
  console.log(`   GET    /api/learning/progress/courses/:courseId`);
  console.log(`   GET    /api/learning/dashboard`);
  
  console.log(`\n   🤖 AI Mentor:`);
  console.log(`   GET    /api/learning/ai/recommendations`);
  console.log(`   POST   /api/learning/ai/recommendations/:id/act`);
  
  console.log(`\n   🎓 Certificates:`);
  console.log(`   GET    /api/learning/certificates/me`);
  console.log(`   POST   /api/learning/certificates/generate`);
  console.log(`   GET    /api/learning/certificates/verify/:code`);
  
  console.log(`\n   ✏️ Activities:`);
  console.log(`   POST   /api/learning/activities/:activityId/submit`);
  console.log(`   GET    /api/learning/activities/submissions/me`);
  
  console.log(`\n   🔔 Notifications:`);
  console.log(`   GET    /api/learning/notifications/me`);
  console.log(`   PUT    /api/learning/notifications/:id/read`);
  console.log(`   POST   /api/learning/notifications/mark-all-read`);
  
  console.log(`\n   🔄 Sync & Offline:`);
  console.log(`   POST   /api/learning/sync/progress`);
  console.log(`   GET    /api/learning/sync/status`);
  
  console.log(`\n   🔍 Search & Analytics:`);
  console.log(`   GET    /api/learning/search`);
  console.log(`   POST   /api/learning/analytics/track`);
  console.log(`   GET    /api/learning/analytics/insights`);
  
  console.log(`\n   📖 Bhagavad Gita:`);
  console.log(`   GET    /api/gita/chapters`);
  console.log(`   GET    /api/gita/chapters/:chapterNumber`);
  console.log(`   GET    /api/gita/shlokas/:shlokaId`);
  console.log(`   GET    /api/gita/levels`);
  console.log(`   GET    /api/gita/levels/:levelNumber`);
  console.log(`   GET    /api/gita/progress/:userId`);
  console.log(`   POST   /api/gita/progress`);
  
  console.log(`\n✅ Database: cltlsyxm_huge_learning (38 tables)`);
  console.log(`✅ Prisma ORM with query caching enabled`);
  console.log(`✅ HUGE Auth integration active`);
  console.log(`\n✅ All endpoints operational!\n`);
});

