# Bhagavad Gita Course Implementation

## ✅ Completed

### 1. Database Schema (Prisma)

**New Models Added:**
- `GitaChapter` - Chapter metadata (18 chapters)
- `GitaShloka` - Individual shlokas (700 shlokas)
- `GitaShlokaTranslation` - Translations in multiple languages (Sanskrit, Hindi, English)
- `GitaShlokaAudio` - Audio files for shlokas
- `UserShlokaProgress` - User progress tracking per shloka

**Schema Features:**
- Chapter-level tracking with level mapping
- Multi-language support (Sanskrit, Hindi, English)
- Audio support (Sanskrit chanting + meaning narration)
- XP rewards per shloka (2 XP default)
- Progress tracking (listened, read, completed)

### 2. Level Structure

**Level 1: KURUKSHETRA & INNER CONFLICT**
- Chapters: 1, 2 (Part A: 1-38)
- Badge: 🛡️ Gita Initiate
- XP Reward: 100

**Level 2: KARMA YOGA**
- Chapters: 2 (Part B: 39-72), 3, 4, 5
- Badge: 🔥 Karma Yogi
- XP Reward: 200

**Level 3: BHAKTI YOGA**
- Chapters: 6, 7, 8, 9, 12
- Badge: 🪔 Bhakti Sadhak
- XP Reward: 200

**Level 4: JNANA YOGA**
- Chapters: 10, 11, 13, 14, 15
- Badge: 🧠 Jnana Seeker
- XP Reward: 250

**Level 5: LIVING THE GITA**
- Chapters: 16, 17, 18
- Badge: 🏹 Gita Warrior
- XP Reward: 250

**Final Badge:** 👑 Gita Jeevan Acharya (500 XP + 100 Karma)

### 3. API Endpoints

**Base URL:** `/api/gita`

- `GET /chapters` - Get all chapters
- `GET /chapters/:chapterNumber` - Get specific chapter with shlokas
- `GET /shlokas/:shlokaId` - Get shloka with translations and audio
- `GET /levels` - Get all 5 levels with chapters
- `GET /levels/:levelNumber` - Get specific level details
- `GET /progress/:userId` - Get user's progress
- `POST /progress` - Update shloka progress

### 4. Seed Data Script

**File:** `backend/prisma/seed-gita.ts`

**Features:**
- Creates all 18 chapters
- Creates badges for each level
- Creates final course completion badge
- Sample shlokas with translations (English & Hindi)
- Ready to extend with all 700 shlokas

**Run:** `npm run prisma:seed-gita`

---

## 📋 Next Steps

### 1. Complete Seed Data
- Add all 700 shlokas with Sanskrit text
- Add translations for all shlokas (English, Hindi)
- Add transliteration for all shlokas
- Add audio file URLs (when available)

### 2. Flutter UI Implementation

**Required Screens:**
- Course overview (5 levels)
- Level detail (chapters in level)
- Chapter detail (shlokas in chapter)
- Shloka viewer (Sanskrit, translation, audio)
- Progress tracker

**Components Needed:**
- `GitaCourseScreen` - Course overview
- `GitaLevelScreen` - Level with chapters
- `GitaChapterScreen` - Chapter with shlokas
- `ShlokaViewerScreen` - Individual shloka view
- `ShlokaProgressWidget` - Progress indicator

### 3. Audio Integration
- Audio player for Sanskrit chanting
- Audio player for meaning narration
- Offline download support
- Background playback

### 4. Gamification
- XP calculation on shloka completion
- Badge unlocking on level completion
- Progress visualization
- Streak tracking

---

## 🗄️ Database Structure

```
GitaChapter (18 rows)
  ├── GitaShloka (700 rows)
  │   ├── GitaShlokaTranslation (2100 rows - 700 × 3 languages)
  │   └── GitaShlokaAudio (1400 rows - 700 × 2 audio types)
  └── UserShlokaProgress (per user, per shloka)
```

---

## 🎯 Gamification Rules

**XP Rewards:**
- Per shloka: 2 XP
- Chapter completion: 20 XP bonus
- Level completion: 100-250 XP (varies by level)
- Course completion: 500 XP + 100 Karma

**Badge Unlocking:**
- Level badges: Unlock on level completion
- Final badge: Unlock on course completion (all 700 shlokas)

**Progress Tracking:**
- `not_started` → `in_progress` → `completed`
- Track: Sanskrit audio listened, meaning audio listened, explanation read
- Optional reflection per shloka

---

## 📱 User Experience Flow

1. **Course Overview**
   - See 5 levels
   - Progress indicator per level
   - Badge preview

2. **Level Selection**
   - See chapters in level
   - Chapter progress
   - Unlock status

3. **Chapter View**
   - List of shlokas
   - Shloka completion status
   - Quick navigation

4. **Shloka Viewer**
   - Sanskrit text (Devanagari)
   - Play Sanskrit audio
   - Translation (selected language)
   - Play meaning audio
   - Explanation / "Why it matters"
   - Mark as complete
   - Optional reflection

---

## 🔧 Technical Notes

**Language Support:**
- Sanskrit (Devanagari) - Fixed, canonical
- Hindi - Full translation
- English - Full translation
- Extensible for more languages

**Audio Design:**
- Sanskrit audio: Professional chanting
- Meaning audio: Natural human voice
- Sync: Text highlights with audio
- Offline: Download per chapter

**Performance:**
- Lazy load shlokas
- Cache translations
- Preload next shloka
- Background sync progress

---

**Status:** ✅ Database schema and API complete | ⏳ Flutter UI pending | ⏳ Full seed data pending



