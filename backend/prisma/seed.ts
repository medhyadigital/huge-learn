import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Create Learning Schools
  const school1 = await prisma.learningSchool.upsert({
    where: { schoolId: 'school-shruti-smriti' },
    update: {},
    create: {
      schoolId: 'school-shruti-smriti',
      schoolName: 'Shruti & Smriti Studies',
      description: 'Study Vedas, Upanishads, Bhagavad Gita, Itihasas, Puranas',
      displayOrder: 1,
      isActive: true,
    },
  });

  const school2 = await prisma.learningSchool.upsert({
    where: { schoolId: 'school-applied-dharma' },
    update: {},
    create: {
      schoolId: 'school-applied-dharma',
      schoolName: 'Applied Dharma',
      description: 'Karma, Bhakti, Jnana Yoga, Leadership, Ethics, Decision Making',
      displayOrder: 2,
      isActive: true,
    },
  });

  const school3 = await prisma.learningSchool.upsert({
    where: { schoolId: 'school-civilization' },
    update: {},
    create: {
      schoolId: 'school-civilization',
      schoolName: 'Hindu Civilization & Thinkers',
      description: 'Ancient Gurus, Bhakti Movement, Freedom Fighters, Modern Thinkers',
      displayOrder: 3,
      isActive: true,
    },
  });

  const school4 = await prisma.learningSchool.upsert({
    where: { schoolId: 'school-sadhana' },
    update: {},
    create: {
      schoolId: 'school-sadhana',
      schoolName: 'Sadhana & Lifestyle',
      description: 'Meditation, Yoga Philosophy, Sanskrit Basics, Hindu Rituals',
      displayOrder: 4,
      isActive: true,
    },
  });

  console.log('✅ Created 4 Learning Schools');

  // Create Sample Course: Bhagavad Gita
  const gitaCourse = await prisma.course.upsert({
    where: { courseSlug: 'bhagavad-gita-life-leadership' },
    update: {},
    create: {
      courseId: 'course-bhagavad-gita',
      schoolId: school1.schoolId,
      courseName: 'Bhagavad Gita – Life & Leadership',
      courseSlug: 'bhagavad-gita-life-leadership',
      shortDescription: 'Learn practical Dharma and decision-making from the Bhagavad Gita',
      longDescription: 'A comprehensive course on applying Bhagavad Gita teachings to modern life challenges, leadership, and ethical decision-making.',
      durationDays: 30,
      difficultyLevel: 'beginner',
      totalLessons: 45,
      estimatedHours: 15.5,
      isFeatured: true,
      isActive: true,
      displayOrder: 1,
    },
  });

  // Create Tracks for Bhagavad Gita
  const beginnerTrack = await prisma.track.upsert({
    where: { trackId: 'track-gita-beginner' },
    update: {},
    create: {
      trackId: 'track-gita-beginner',
      courseId: gitaCourse.courseId,
      trackName: 'Beginner Track - Foundation',
      trackLevel: 'beginner',
      description: 'Understand context, core ideas, and basic application',
      displayOrder: 1,
      isActive: true,
    },
  });

  const intermediateTrack = await prisma.track.upsert({
    where: { trackId: 'track-gita-intermediate' },
    update: {},
    create: {
      trackId: 'track-gita-intermediate',
      courseId: gitaCourse.courseId,
      trackName: 'Intermediate Track - Application',
      trackLevel: 'intermediate',
      description: 'Apply Gita teachings to real-life scenarios',
      unlockCriteria: { previousTrackId: beginnerTrack.trackId, minScore: 70 },
      displayOrder: 2,
      isActive: true,
    },
  });

  const advancedTrack = await prisma.track.upsert({
    where: { trackId: 'track-gita-advanced' },
    update: {},
    create: {
      trackId: 'track-gita-advanced',
      courseId: gitaCourse.courseId,
      trackName: 'Advanced Track - Mastery & Seva',
      trackLevel: 'advanced',
      description: 'Deep insights, teaching others, living Gita through Seva',
      unlockCriteria: { previousTrackId: intermediateTrack.trackId, minScore: 80 },
      displayOrder: 3,
      isActive: true,
    },
  });

  console.log('✅ Created Bhagavad Gita course with 3 tracks');

  // Create Modules for Beginner Track
  const module1 = await prisma.module.upsert({
    where: { moduleId: 'module-gita-context' },
    update: {},
    create: {
      moduleId: 'module-gita-context',
      trackId: beginnerTrack.trackId,
      moduleName: 'Kurukshetra Context & Characters',
      description: 'Understand the historical and spiritual context of Bhagavad Gita',
      displayOrder: 1,
      isActive: true,
    },
  });

  const module2 = await prisma.module.upsert({
    where: { moduleId: 'module-what-is-dharma' },
    update: {},
    create: {
      moduleId: 'module-what-is-dharma',
      trackId: beginnerTrack.trackId,
      moduleName: 'What is Dharma?',
      description: 'Core concept of Dharma and its application',
      displayOrder: 2,
      isActive: true,
    },
  });

  console.log('✅ Created 2 modules in Beginner Track');

  // Create Sample Lessons
  const lesson1 = await prisma.lesson.upsert({
    where: { lessonId: 'lesson-gita-intro' },
    update: {},
    create: {
      lessonId: 'lesson-gita-intro',
      moduleId: module1.moduleId,
      lessonName: 'Introduction to Bhagavad Gita',
      lessonType: 'mixed',
      content: {
        slides: [
          {
            type: 'text',
            title: 'Welcome to Bhagavad Gita',
            body: 'The Bhagavad Gita is a 700-verse Hindu scripture that is part of the epic Mahabharata. It presents a synthesis of Hindu ideas about dharma, theistic bhakti, and the yogic paths to moksha.',
            duration_seconds: 90,
          },
          {
            type: 'text',
            title: 'Historical Context',
            body: 'The Gita is set in a narrative framework of a dialogue between Pandava prince Arjuna and his guide and charioteer Krishna. At the start, Arjuna is in crisis, filled with doubt about the righteousness of war.',
            duration_seconds: 90,
          },
          {
            type: 'text',
            title: 'Core Message',
            body: 'Krishna counsels Arjuna to "fulfill his Kshatriya (warrior) duty" as a warrior and establish Dharma. The Gita covers topics such as: duty, devotion, knowledge, and yoga.',
            duration_seconds: 90,
          },
        ],
      },
      durationMinutes: 5,
      hasQuiz: true,
      hasReflection: false,
      displayOrder: 1,
      isActive: true,
    },
  });

  const lesson2 = await prisma.lesson.upsert({
    where: { lessonId: 'lesson-dharma-basics' },
    update: {},
    create: {
      lessonId: 'lesson-dharma-basics',
      moduleId: module2.moduleId,
      lessonName: 'Understanding Dharma',
      lessonType: 'text',
      content: {
        slides: [
          {
            type: 'text',
            title: 'What is Dharma?',
            body: 'Dharma is a Sanskrit word that has multiple meanings. In the context of Hinduism, it refers to righteousness, duty, law, and the path of morality.',
            duration_seconds: 90,
          },
          {
            type: 'text',
            title: 'Four Types of Dharma',
            body: '1. Rita - Universal law\n2. Varna Dharma - Duty according to one\'s nature\n3. Ashrama Dharma - Duty according to life stage\n4. Svadharma - Personal dharma',
            duration_seconds: 120,
          },
        ],
      },
      durationMinutes: 4,
      hasQuiz: true,
      hasReflection: true,
      displayOrder: 1,
      isActive: true,
    },
  });

  console.log('✅ Created 2 sample lessons');

  // Create Quiz for Lesson 1
  await prisma.quiz.upsert({
    where: { quizId: 'quiz-gita-intro' },
    update: {},
    create: {
      quizId: 'quiz-gita-intro',
      lessonId: lesson1.lessonId,
      quizName: 'Gita Introduction Quiz',
      quizType: 'mcq',
      questions: [
        {
          questionId: 'q1',
          questionText: 'How many verses are there in the Bhagavad Gita?',
          questionType: 'mcq',
          options: [
            { id: 'a', text: '500 verses' },
            { id: 'b', text: '700 verses' },
            { id: 'c', text: '900 verses' },
            { id: 'd', text: '1000 verses' },
          ],
          correctAnswer: 'b',
          explanation: 'The Bhagavad Gita consists of 700 verses.',
          points: 10,
        },
        {
          questionId: 'q2',
          questionText: 'Who is the teacher in Bhagavad Gita?',
          questionType: 'mcq',
          options: [
            { id: 'a', text: 'Arjuna' },
            { id: 'b', text: 'Krishna' },
            { id: 'c', text: 'Vyasa' },
            { id: 'd', text: 'Brahma' },
          ],
          correctAnswer: 'b',
          explanation: 'Lord Krishna is the teacher who guides Arjuna.',
          points: 10,
        },
      ],
      passingScore: 70,
      maxAttempts: 3,
      timeLimitMinutes: 10,
    },
  });

  console.log('✅ Created quiz for Gita Introduction');

  // Create Badges
  await prisma.badge.upsert({
    where: { badgeSlug: 'gita-sadhak' },
    update: {},
    create: {
      badgeId: 'badge-gita-sadhak',
      badgeName: 'Gita Sadhak',
      badgeSlug: 'gita-sadhak',
      description: 'Completed Beginner Track of Bhagavad Gita',
      badgeCategory: 'learning',
      criteria: {
        type: 'track_completion',
        trackId: beginnerTrack.trackId,
      },
      xpReward: 500,
      karmaReward: 100,
      isActive: true,
    },
  });

  await prisma.badge.upsert({
    where: { badgeSlug: 'first-lesson' },
    update: {},
    create: {
      badgeId: 'badge-first-lesson',
      badgeName: 'First Step',
      badgeSlug: 'first-lesson',
      description: 'Completed your first lesson',
      badgeCategory: 'achievement',
      criteria: {
        type: 'lesson_completion',
        count: 1,
      },
      xpReward: 50,
      karmaReward: 10,
      isActive: true,
    },
  });

  console.log('✅ Created 2 badges');

  // Create another course
  const vedasCourse = await prisma.course.upsert({
    where: { courseSlug: 'vedas-foundation' },
    update: {},
    create: {
      courseId: 'course-vedas',
      schoolId: school1.schoolId,
      courseName: 'Vedas - Foundation',
      courseSlug: 'vedas-foundation',
      shortDescription: 'Introduction to the four Vedas and their significance',
      longDescription: 'Explore the foundational texts of Hindu philosophy: Rigveda, Yajurveda, Samaveda, and Atharvaveda.',
      durationDays: 21,
      difficultyLevel: 'beginner',
      totalLessons: 30,
      estimatedHours: 10.0,
      isFeatured: false,
      isActive: true,
      displayOrder: 2,
    },
  });

  console.log('✅ Created Vedas course');

  console.log('\n✅ Database seeding completed successfully!');
  console.log('\n📊 Summary:');
  console.log('   - 4 Learning Schools');
  console.log('   - 2 Courses (Bhagavad Gita, Vedas)');
  console.log('   - 3 Tracks (Beginner, Intermediate, Advanced)');
  console.log('   - 2 Modules');
  console.log('   - 2 Lessons with content');
  console.log('   - 1 Quiz with questions');
  console.log('   - 2 Badges\n');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });



