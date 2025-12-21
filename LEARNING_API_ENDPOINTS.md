# HUGE Learning Platform - API Endpoints

## Base URL
```
Production: https://huge.imedhya.com/api/learning
Development: http://localhost:3000/api/learning
```

## Authentication
All endpoints require Bearer token from HUGE Foundations Auth:
```
Authorization: Bearer {access_token}
```

---

## 📚 1. Learning Schools

### GET /schools
Get all learning schools

**Response:**
```json
{
  "schools": [
    {
      "school_id": "uuid",
      "school_name": "Shruti & Smriti Studies",
      "description": "Study Vedas, Upanishads...",
      "icon_url": "https://cdn.../icon.png",
      "display_order": 1,
      "course_count": 12
    }
  ]
}
```

---

## 📖 2. Courses

### GET /schools/{schoolId}/courses
Get courses in a school

**Query Params:**
- `page` (default: 1)
- `limit` (default: 20)
- `level` (optional): beginner|intermediate|advanced
- `featured` (optional): true|false

**Response:**
```json
{
  "courses": [
    {
      "course_id": "uuid",
      "course_name": "Bhagavad Gita – Life & Leadership",
      "course_slug": "bhagavad-gita-life-leadership",
      "short_description": "...",
      "thumbnail_url": "...",
      "difficulty_level": "beginner",
      "duration_days": 30,
      "total_lessons": 45,
      "estimated_hours": 15.5,
      "is_featured": true,
      "enrollment_status": "enrolled|not_enrolled"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_items": 45
  }
}
```

### GET /courses/{courseId}
Get course details

**Response:**
```json
{
  "course_id": "uuid",
  "school_id": "uuid",
  "course_name": "Bhagavad Gita – Life & Leadership",
  "course_slug": "bhagavad-gita-life-leadership",
  "long_description": "Full description...",
  "thumbnail_url": "...",
  "banner_url": "...",
  "difficulty_level": "beginner",
  "duration_days": 30,
  "total_lessons": 45,
  "estimated_hours": 15.5,
  "tracks": [
    {
      "track_id": "uuid",
      "track_name": "Beginner Track",
      "track_level": "beginner",
      "description": "...",
      "module_count": 5,
      "lesson_count": 15,
      "is_unlocked": true
    }
  ],
  "user_progress": {
    "is_enrolled": true,
    "enrollment_id": "uuid",
    "completion_percentage": 45.5,
    "current_track_id": "uuid",
    "current_lesson_id": "uuid",
    "last_accessed_at": "2024-01-15T10:00:00Z"
  }
}
```

### POST /courses/{courseId}/enroll
Enroll in a course

**Response:**
```json
{
  "enrollment_id": "uuid",
  "course_id": "uuid",
  "user_id": "uuid",
  "enrolled_at": "2024-01-15T10:00:00Z",
  "first_lesson_id": "uuid"
}
```

---

## 🎯 3. Tracks & Modules

### GET /tracks/{trackId}/modules
Get modules in a track

**Response:**
```json
{
  "modules": [
    {
      "module_id": "uuid",
      "module_name": "Kurukshetra Context & Characters",
      "description": "...",
      "lesson_count": 5,
      "display_order": 1,
      "user_progress": {
        "completed_lessons": 3,
        "total_lessons": 5,
        "is_completed": false
      }
    }
  ]
}
```

### GET /modules/{moduleId}/lessons
Get lessons in a module

**Response:**
```json
{
  "lessons": [
    {
      "lesson_id": "uuid",
      "lesson_name": "Introduction to Bhagavad Gita",
      "lesson_type": "video",
      "duration_minutes": 5,
      "display_order": 1,
      "has_quiz": true,
      "has_reflection": true,
      "is_completed": false,
      "progress_percentage": 50.0
    }
  ]
}
```

---

## 📝 4. Lessons

### GET /lessons/{lessonId}
Get lesson content

**Response:**
```json
{
  "lesson_id": "uuid",
  "lesson_name": "Introduction to Bhagavad Gita",
  "lesson_type": "video",
  "content": {
    "type": "video",
    "slides": [
      {
        "type": "text",
        "title": "Context",
        "body": "The Bhagavad Gita...",
        "duration_seconds": 60
      },
      {
        "type": "video",
        "title": "Overview",
        "video_url": "https://cdn.../video.mp4",
        "thumbnail_url": "...",
        "duration_seconds": 180
      },
      {
        "type": "audio",
        "title": "Shloka Recitation",
        "audio_url": "https://cdn.../audio.mp3",
        "transcript": "...",
        "duration_seconds": 120
      }
    ]
  },
  "duration_minutes": 5,
  "has_quiz": true,
  "has_reflection": true,
  "user_progress": {
    "status": "in_progress",
    "progress_percentage": 50.0,
    "last_slide_index": 1,
    "time_spent_seconds": 150
  },
  "next_lesson_id": "uuid",
  "previous_lesson_id": "uuid"
}
```

### POST /lessons/{lessonId}/progress
Update lesson progress

**Request:**
```json
{
  "progress_percentage": 75.0,
  "completed_slide_index": 2,
  "time_spent_seconds": 300,
  "is_completed": false
}
```

**Response:**
```json
{
  "progress_id": "uuid",
  "lesson_id": "uuid",
  "progress_percentage": 75.0,
  "status": "in_progress",
  "xp_earned": 10
}
```

### POST /lessons/{lessonId}/complete
Mark lesson as complete

**Response:**
```json
{
  "progress_id": "uuid",
  "lesson_id": "uuid",
  "status": "completed",
  "completed_at": "2024-01-15T10:30:00Z",
  "rewards": {
    "xp": 50,
    "karma": 10,
    "badges": ["gita-learner"],
    "next_lesson_unlocked": true
  },
  "next_lesson_id": "uuid"
}
```

---

## ❓ 5. Quizzes

### GET /quizzes/{quizId}
Get quiz questions

**Response:**
```json
{
  "quiz_id": "uuid",
  "lesson_id": "uuid",
  "quiz_name": "Gita Basics Quiz",
  "quiz_type": "mcq",
  "passing_score": 70,
  "max_attempts": 3,
  "time_limit_minutes": 10,
  "questions": [
    {
      "question_id": "uuid",
      "question_text": "What is Dharma?",
      "question_type": "mcq",
      "options": [
        {"id": "a", "text": "Religion"},
        {"id": "b", "text": "Duty"},
        {"id": "c", "text": "Both A and B"},
        {"id": "d", "text": "None"}
      ],
      "points": 10
    }
  ],
  "user_attempts": {
    "attempts_taken": 1,
    "best_score": 80.0,
    "last_attempt_at": "2024-01-10T10:00:00Z"
  }
}
```

### POST /quizzes/{quizId}/submit
Submit quiz answers

**Request:**
```json
{
  "answers": [
    {"question_id": "uuid", "selected_option": "c"}
  ],
  "time_taken_seconds": 300
}
```

**Response:**
```json
{
  "attempt_id": "uuid",
  "score": 90.0,
  "passed": true,
  "correct_answers": 9,
  "total_questions": 10,
  "time_taken_seconds": 300,
  "rewards": {
    "xp": 100,
    "karma": 20
  },
  "results": [
    {
      "question_id": "uuid",
      "is_correct": true,
      "selected_option": "c",
      "correct_option": "c",
      "explanation": "..."
    }
  ]
}
```

---

## 🎮 6. Gamification

### GET /gamification/metrics
Get user's gamification metrics

**Response:**
```json
{
  "user_id": "uuid",
  "total_xp": 2500,
  "total_karma": 450,
  "wisdom_level": 5,
  "current_streak": 7,
  "longest_streak": 15,
  "total_lessons_completed": 45,
  "total_courses_completed": 2,
  "total_time_spent_minutes": 1200,
  "badges_earned": 12,
  "rank": "Gita Sadhak",
  "next_level_xp": 3000
}
```

### GET /gamification/badges
Get user's badges

**Response:**
```json
{
  "badges": [
    {
      "badge_id": "uuid",
      "badge_name": "Gita Sadhak",
      "description": "Completed Beginner Track",
      "badge_icon_url": "...",
      "badge_category": "learning",
      "earned_at": "2024-01-10T10:00:00Z"
    }
  ],
  "available_badges": [
    {
      "badge_id": "uuid",
      "badge_name": "Karma Yogi",
      "description": "Complete 10 seva activities",
      "badge_icon_url": "...",
      "progress": {
        "current": 5,
        "required": 10,
        "percentage": 50.0
      }
    }
  ]
}
```

### GET /gamification/leaderboard
Get leaderboard

**Query Params:**
- `type`: xp|karma|streak
- `scope`: global|friends|course
- `period`: week|month|all_time
- `limit` (default: 50)

**Response:**
```json
{
  "leaderboard": [
    {
      "rank": 1,
      "user_id": "uuid",
      "display_name": "Arjun K",
      "avatar_url": "...",
      "score": 5000,
      "badge_count": 15
    }
  ],
  "current_user_rank": {
    "rank": 42,
    "score": 2500
  }
}
```

---

## 🤖 7. AI Mentor

### GET /ai/recommendations
Get personalized recommendations

**Response:**
```json
{
  "recommendations": [
    {
      "recommendation_id": "uuid",
      "type": "next_course",
      "title": "Try Karma Yoga Course",
      "description": "Based on your Gita completion...",
      "target_id": "uuid",
      "priority": 80,
      "action_text": "Start Course",
      "action_url": "/courses/uuid"
    },
    {
      "recommendation_id": "uuid",
      "type": "weak_topic",
      "title": "Review Mind Control",
      "description": "You scored low on this topic...",
      "target_id": "uuid",
      "priority": 60,
      "action_text": "Review Lesson",
      "action_url": "/lessons/uuid"
    }
  ]
}
```

### POST /ai/recommendations/{recommendationId}/act
Mark recommendation as acted upon

---

## 📊 8. Progress & Analytics

### GET /progress/me
Get user's overall progress

**Response:**
```json
{
  "enrollments": [
    {
      "enrollment_id": "uuid",
      "course_id": "uuid",
      "course_name": "Bhagavad Gita",
      "thumbnail_url": "...",
      "completion_percentage": 45.5,
      "current_lesson": {
        "lesson_id": "uuid",
        "lesson_name": "Mind Control"
      },
      "last_accessed_at": "2024-01-15T10:00:00Z",
      "status": "in_progress"
    }
  ],
  "summary": {
    "total_courses_enrolled": 5,
    "total_courses_completed": 2,
    "total_lessons_completed": 45,
    "total_time_spent_minutes": 1200,
    "this_week_minutes": 150
  }
}
```

### GET /progress/courses/{courseId}
Get detailed course progress

**Response:**
```json
{
  "enrollment_id": "uuid",
  "course_id": "uuid",
  "completion_percentage": 45.5,
  "tracks": [
    {
      "track_id": "uuid",
      "track_name": "Beginner",
      "is_unlocked": true,
      "is_current": true,
      "completion_percentage": 100.0,
      "modules": [
        {
          "module_id": "uuid",
          "module_name": "Context",
          "completed_lessons": 5,
          "total_lessons": 5,
          "is_completed": true
        }
      ]
    }
  ],
  "recent_lessons": [
    {
      "lesson_id": "uuid",
      "lesson_name": "...",
      "completed_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

---

## 🎓 9. Certificates

### GET /certificates/me
Get user's certificates

**Response:**
```json
{
  "certificates": [
    {
      "certificate_id": "uuid",
      "course_id": "uuid",
      "course_name": "Bhagavad Gita",
      "certificate_type": "completion",
      "certificate_number": "HUG-BG-2024-001234",
      "issue_date": "2024-01-15",
      "certificate_url": "https://cdn.../cert.pdf",
      "verification_code": "ABC123XYZ",
      "is_shareable": true
    }
  ]
}
```

### POST /certificates/generate
Request certificate generation

**Request:**
```json
{
  "course_id": "uuid",
  "certificate_type": "completion"
}
```

---

## 🔔 10. Notifications

### GET /notifications/me
Get user notifications

**Query Params:**
- `page` (default: 1)
- `limit` (default: 20)
- `unread_only` (default: false)

**Response:**
```json
{
  "notifications": [
    {
      "notification_id": "uuid",
      "type": "badge_earned",
      "title": "New Badge Earned!",
      "message": "You earned the Gita Sadhak badge",
      "data": {
        "badge_id": "uuid",
        "deep_link": "/badges/uuid"
      },
      "is_read": false,
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "unread_count": 5
}
```

### PUT /notifications/{notificationId}/read
Mark notification as read

---

## 📱 11. Sync & Offline Support

### POST /sync/progress
Bulk sync progress (for offline mode)

**Request:**
```json
{
  "syncs": [
    {
      "lesson_id": "uuid",
      "progress_percentage": 100.0,
      "is_completed": true,
      "time_spent_seconds": 300,
      "completed_at": "2024-01-15T10:00:00Z",
      "device_timestamp": "2024-01-15T10:00:00Z"
    }
  ]
}
```

**Response:**
```json
{
  "synced_count": 5,
  "failed_count": 0,
  "rewards": {
    "total_xp": 250,
    "total_karma": 50,
    "new_badges": ["streak-master"]
  }
}
```

---

## ⚡ Performance & Caching

### Cache Headers
All GET endpoints return caching headers:
```
Cache-Control: max-age=300, must-revalidate
ETag: "abc123"
```

### Pagination
All list endpoints support pagination:
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)

### Response Format
All responses follow this format:
```json
{
  "data": {...},
  "meta": {
    "timestamp": "2024-01-15T10:00:00Z",
    "version": "1.0"
  }
}
```

### Error Format
All errors follow this format:
```json
{
  "error": {
    "code": "LESSON_NOT_FOUND",
    "message": "Lesson with ID xxx not found",
    "details": {...}
  }
}
```

---

## 🔐 Rate Limiting

- **General endpoints**: 100 requests/minute/user
- **Progress endpoints**: 300 requests/minute/user
- **Sync endpoints**: 10 requests/minute/user

Headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642251600
```

---

## 🌍 Versioning

API versioning via header:
```
Accept: application/vnd.huge-learning.v1+json
```

Future versions will be backward compatible.



