import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Level mapping as per design
const LEVEL_MAPPING = {
  1: {
    name: 'KURUKSHETRA & INNER CONFLICT',
    subtitle: 'The Problem of Human Life',
    chapters: [1, 2], // Chapter 2 is partial (1-38)
    badgeName: 'Gita Initiate',
    badgeSlug: 'gita-initiate',
    badgeIcon: '🛡️',
    xpReward: 100,
  },
  2: {
    name: 'KARMA YOGA',
    subtitle: 'Right Action, Right Attitude',
    chapters: [2, 3, 4, 5], // Chapter 2 is partial (39-72)
    badgeName: 'Karma Yogi',
    badgeSlug: 'karma-yogi',
    badgeIcon: '🔥',
    xpReward: 200,
  },
  3: {
    name: 'BHAKTI YOGA',
    subtitle: 'Devotion, Faith & Surrender',
    chapters: [6, 7, 8, 9, 12],
    badgeName: 'Bhakti Sadhak',
    badgeSlug: 'bhakti-sadhak',
    badgeIcon: '🪔',
    xpReward: 200,
  },
  4: {
    name: 'JNANA YOGA',
    subtitle: 'Wisdom, Detachment & the Self',
    chapters: [10, 11, 13, 14, 15],
    badgeName: 'Jnana Seeker',
    badgeSlug: 'jnana-seeker',
    badgeIcon: '🧠',
    xpReward: 250,
  },
  5: {
    name: 'LIVING THE GITA',
    subtitle: 'From Knowledge to Dharma',
    chapters: [16, 17, 18],
    badgeName: 'Gita Warrior',
    badgeSlug: 'gita-warrior',
    badgeIcon: '🏹',
    xpReward: 250,
  },
};

// Chapter metadata (simplified - you'll need to add all 18 chapters)
const CHAPTER_DATA = [
  {
    number: 1,
    name: 'Arjuna Vishada Yoga',
    nameSanskrit: 'अर्जुनविषादयोगः',
    description: 'The Yoga of Arjuna\'s Dejection',
    totalShlokas: 47,
    level: 1,
  },
  {
    number: 2,
    name: 'Sankhya Yoga',
    nameSanskrit: 'साङ्ख्ययोगः',
    description: 'The Yoga of Knowledge',
    totalShlokas: 72,
    level: 1, // Part A (1-38) in Level 1, Part B (39-72) in Level 2
  },
  {
    number: 3,
    name: 'Karma Yoga',
    nameSanskrit: 'कर्मयोगः',
    description: 'The Yoga of Action',
    totalShlokas: 43,
    level: 2,
  },
  {
    number: 4,
    name: 'Jnana-Karma Sanyasa Yoga',
    nameSanskrit: 'ज्ञानकर्मसन्यासयोगः',
    description: 'The Yoga of Knowledge and Renunciation of Action',
    totalShlokas: 42,
    level: 2,
  },
  {
    number: 5,
    name: 'Karma Sanyasa Yoga',
    nameSanskrit: 'कर्मसन्यासयोगः',
    description: 'The Yoga of Renunciation of Action',
    totalShlokas: 29,
    level: 2,
  },
  {
    number: 6,
    name: 'Dhyana Yoga',
    nameSanskrit: 'ध्यानयोगः',
    description: 'The Yoga of Meditation',
    totalShlokas: 47,
    level: 3,
  },
  {
    number: 7,
    name: 'Jnana-Vijnana Yoga',
    nameSanskrit: 'ज्ञानविज्ञानयोगः',
    description: 'The Yoga of Knowledge and Wisdom',
    totalShlokas: 30,
    level: 3,
  },
  {
    number: 8,
    name: 'Akshara Brahma Yoga',
    nameSanskrit: 'अक्षरब्रह्मयोगः',
    description: 'The Yoga of the Imperishable Brahman',
    totalShlokas: 28,
    level: 3,
  },
  {
    number: 9,
    name: 'Raja Vidya Raja Guhya Yoga',
    nameSanskrit: 'राजविद्याराजगुह्ययोगः',
    description: 'The Yoga of Royal Knowledge and Royal Secret',
    totalShlokas: 34,
    level: 3,
  },
  {
    number: 10,
    name: 'Vibhuti Yoga',
    nameSanskrit: 'विभूतियोगः',
    description: 'The Yoga of Divine Glories',
    totalShlokas: 42,
    level: 4,
  },
  {
    number: 11,
    name: 'Vishvarupa Darshana Yoga',
    nameSanskrit: 'विश्वरूपदर्शनयोगः',
    description: 'The Yoga of the Vision of the Universal Form',
    totalShlokas: 55,
    level: 4,
  },
  {
    number: 12,
    name: 'Bhakti Yoga',
    nameSanskrit: 'भक्तियोगः',
    description: 'The Yoga of Devotion',
    totalShlokas: 20,
    level: 3,
  },
  {
    number: 13,
    name: 'Kshetra-Kshetragya Yoga',
    nameSanskrit: 'क्षेत्रक्षेत्रज्ञयोगः',
    description: 'The Yoga of the Field and the Knower of the Field',
    totalShlokas: 34,
    level: 4,
  },
  {
    number: 14,
    name: 'Gunatraya Vibhaga Yoga',
    nameSanskrit: 'गुणत्रयविभागयोगः',
    description: 'The Yoga of the Division of the Three Gunas',
    totalShlokas: 27,
    level: 4,
  },
  {
    number: 15,
    name: 'Purushottama Yoga',
    nameSanskrit: 'पुरुषोत्तमयोगः',
    description: 'The Yoga of the Supreme Person',
    totalShlokas: 20,
    level: 4,
  },
  {
    number: 16,
    name: 'Daivasura Sampad Yoga',
    nameSanskrit: 'दैवासुरसम्पद्विभागयोगः',
    description: 'The Yoga of the Division between the Divine and Demoniacal',
    totalShlokas: 24,
    level: 5,
  },
  {
    number: 17,
    name: 'Shraddhatraya Vibhaga Yoga',
    nameSanskrit: 'श्रद्धात्रयविभागयोगः',
    description: 'The Yoga of the Threefold Division of Faith',
    totalShlokas: 28,
    level: 5,
  },
  {
    number: 18,
    name: 'Moksha Sanyasa Yoga',
    nameSanskrit: 'मोक्षसन्यासयोगः',
    description: 'The Yoga of Liberation and Renunciation',
    totalShlokas: 78,
    level: 5,
  },
];

async function seedGita() {
  console.log('🌺 Seeding Bhagavad Gita Course...');

  // Create badges for each level
  for (const [levelNum, levelData] of Object.entries(LEVEL_MAPPING)) {
    await prisma.badge.upsert({
      where: { badgeSlug: levelData.badgeSlug },
      update: {},
      create: {
        badgeName: levelData.badgeName,
        badgeSlug: levelData.badgeSlug,
        description: `Earned by completing Level ${levelNum}: ${levelData.name}`,
        badgeCategory: 'achievement',
        xpReward: levelData.xpReward,
        criteria: {
          level: parseInt(levelNum),
          type: 'level_completion',
        },
      },
    });
  }

  // Create final course completion badge
  await prisma.badge.upsert({
    where: { badgeSlug: 'gita-jeevan-acharya' },
    update: {},
    create: {
      badgeName: 'Gita Jeevan Acharya',
      badgeSlug: 'gita-jeevan-acharya',
      description: 'Master of Bhagavad Gita - Completed all 18 chapters and 700 shlokas',
      badgeCategory: 'achievement',
      xpReward: 500,
      karmaReward: 100,
      criteria: {
        type: 'course_completion',
        courseSlug: 'bhagavad-gita-living-dharma',
      },
    },
  });

  // Create chapters
  for (const chapter of CHAPTER_DATA) {
    await prisma.gitaChapter.upsert({
      where: { chapterNumber: chapter.number },
      update: {
        chapterName: chapter.name,
        chapterNameSanskrit: chapter.nameSanskrit,
        description: chapter.description,
        totalShlokas: chapter.totalShlokas,
        levelNumber: chapter.level,
      },
      create: {
        chapterId: chapter.number,
        chapterNumber: chapter.number,
        chapterName: chapter.name,
        chapterNameSanskrit: chapter.nameSanskrit,
        description: chapter.description,
        totalShlokas: chapter.totalShlokas,
        levelNumber: chapter.level,
        displayOrder: chapter.number,
      },
    });
  }

  // Create sample shlokas (you'll need to add all 700)
  // For now, creating structure for Chapter 1 as example
  const sampleShlokas = [
    {
      chapterNumber: 1,
      shlokaNumber: 1,
      sanskritText: 'धृतराष्ट्र उवाच | धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः | मामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय || 1-1 ||',
      transliteration: 'dhṛtarāṣṭra uvāca | dharmakṣetre kurukṣetre samavetā yuyutsavaḥ | māmakāḥ pāṇḍavāścaiva kimakurvata sañjaya || 1-1 ||',
    },
    {
      chapterNumber: 1,
      shlokaNumber: 2,
      sanskritText: 'सञ्जय उवाच | दृष्ट्वा तु पाण्डवानीकं व्यूढं दुर्योधनस्तदा | आचार्यमुपसङ्गम्य राजा वचनमब्रवीत् || 1-2 ||',
      transliteration: 'sañjaya uvāca | dṛṣṭvā tu pāṇḍavānīkaṃ vyūḍhaṃ duryodhanastadā | ācāryamupasaṅgamya rājā vacanamabravīt || 1-2 ||',
    },
  ];

  for (const shlokaData of sampleShlokas) {
    const chapter = await prisma.gitaChapter.findUnique({
      where: { chapterNumber: shlokaData.chapterNumber },
    });

    if (chapter) {
      await prisma.gitaShloka.upsert({
        where: {
          chapterId_shlokaNumber: {
            chapterId: chapter.chapterId,
            shlokaNumber: shlokaData.shlokaNumber,
          },
        },
        update: {
          sanskritText: shlokaData.sanskritText,
          transliteration: shlokaData.transliteration,
        },
        create: {
          chapterId: chapter.chapterId,
          shlokaNumber: shlokaData.shlokaNumber,
          sanskritText: shlokaData.sanskritText,
          transliteration: shlokaData.transliteration,
          displayOrder: shlokaData.shlokaNumber,
          xpReward: 2,
        },
      });
    }
  }

  // Create sample translations (English and Hindi)
  const shlokas = await prisma.gitaShloka.findMany({
    take: 2,
  });

  for (const shloka of shlokas) {
    // English translation
    await prisma.gitaShlokaTranslation.upsert({
      where: {
        shlokaId_language: {
          shlokaId: shloka.shlokaId,
          language: 'en',
        },
      },
      update: {},
      create: {
        shlokaId: shloka.shlokaId,
        language: 'en',
        meaning: 'King Dhritarashtra said: O Sanjaya, what did my sons and the sons of Pandu do when they assembled at the holy place of Kurukshetra, eager for battle?',
        explanation: 'This is the opening verse of the Bhagavad Gita. Dhritarashtra, the blind king, asks his minister Sanjaya about the events on the battlefield of Kurukshetra.',
        whyItMatters: 'This verse sets the context for the entire Gita - a battlefield where the greatest spiritual teaching will be delivered.',
      },
    });

    // Hindi translation
    await prisma.gitaShlokaTranslation.upsert({
      where: {
        shlokaId_language: {
          shlokaId: shloka.shlokaId,
          language: 'hi',
        },
      },
      update: {},
      create: {
        shlokaId: shloka.shlokaId,
        language: 'hi',
        meaning: 'धृतराष्ट्र ने कहा: हे संजय, मेरे पुत्रों और पाण्डवों ने क्या किया जब वे युद्ध के लिए उत्सुक होकर धर्मक्षेत्र कुरुक्षेत्र में एकत्र हुए?',
        explanation: 'यह भगवद गीता का प्रारंभिक श्लोक है। अंधे राजा धृतराष्ट्र अपने मंत्री संजय से कुरुक्षेत्र के युद्धक्षेत्र की घटनाओं के बारे में पूछते हैं।',
        whyItMatters: 'यह श्लोक पूरी गीता के संदर्भ को स्थापित करता है - एक युद्धक्षेत्र जहाँ सबसे बड़ी आध्यात्मिक शिक्षा दी जाएगी।',
      },
    });
  }

  console.log('✅ Bhagavad Gita seed data created!');
  console.log('📝 Note: This is a sample. You need to add all 700 shlokas with their translations.');
}

seedGita()
  .catch((e) => {
    console.error('❌ Error seeding Gita:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

