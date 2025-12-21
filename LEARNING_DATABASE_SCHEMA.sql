-- ============================================================================
-- HUGE Learning Platform - MySQL Database Schema
-- Database: cltlsyxm_HUGE_Learning
-- Optimized for: Mobile read-heavy usage, pagination, resume progress
-- ============================================================================

-- Create database (if not exists)
CREATE DATABASE IF NOT EXISTS cltlsyxm_HUGE_Learning
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cltlsyxm_HUGE_Learning;

-- ============================================================================
-- 1. LEARNING CONTENT HIERARCHY
-- ============================================================================

-- Learning Schools (Top-level categories)
CREATE TABLE learning_schools (
    school_id VARCHAR(36) PRIMARY KEY,
    school_name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_active_order (is_active, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Courses (Under schools)
CREATE TABLE courses (
    course_id VARCHAR(36) PRIMARY KEY,
    school_id VARCHAR(36) NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    course_slug VARCHAR(255) NOT NULL UNIQUE,
    short_description VARCHAR(500),
    long_description TEXT,
    thumbnail_url VARCHAR(500),
    banner_url VARCHAR(500),
    duration_days INT DEFAULT 30,
    difficulty_level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
    total_lessons INT DEFAULT 0,
    estimated_hours DECIMAL(5,2) DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (school_id) REFERENCES learning_schools(school_id) ON DELETE CASCADE,
    INDEX idx_school_active (school_id, is_active),
    INDEX idx_featured (is_featured, is_active),
    INDEX idx_slug (course_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tracks (Beginner/Intermediate/Advanced within a course)
CREATE TABLE tracks (
    track_id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL,
    track_name VARCHAR(255) NOT NULL,
    track_level ENUM('beginner', 'intermediate', 'advanced') NOT NULL,
    description TEXT,
    unlock_criteria JSON, -- {"previous_track_id": "xxx", "min_score": 80}
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    INDEX idx_course_level (course_id, track_level),
    INDEX idx_course_order (course_id, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Modules (Groups of lessons within a track)
CREATE TABLE modules (
    module_id VARCHAR(36) PRIMARY KEY,
    track_id VARCHAR(36) NOT NULL,
    module_name VARCHAR(255) NOT NULL,
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE,
    INDEX idx_track_order (track_id, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Lessons (Individual learning units)
CREATE TABLE lessons (
    lesson_id VARCHAR(36) PRIMARY KEY,
    module_id VARCHAR(36) NOT NULL,
    lesson_name VARCHAR(255) NOT NULL,
    lesson_type ENUM('text', 'video', 'audio', 'carousel', 'mixed') DEFAULT 'text',
    content JSON NOT NULL, -- Full lesson content as JSON
    duration_minutes INT DEFAULT 3,
    has_quiz BOOLEAN DEFAULT FALSE,
    has_reflection BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE,
    INDEX idx_module_order (module_id, display_order),
    INDEX idx_type (lesson_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Activities (Interactive elements within lessons)
CREATE TABLE activities (
    activity_id VARCHAR(36) PRIMARY KEY,
    lesson_id VARCHAR(36) NOT NULL,
    activity_type ENUM('reflection', 'practice', 'discussion', 'seva_task') NOT NULL,
    content JSON NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    INDEX idx_lesson_type (lesson_id, activity_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Quizzes (Assessments for lessons)
CREATE TABLE quizzes (
    quiz_id VARCHAR(36) PRIMARY KEY,
    lesson_id VARCHAR(36) NOT NULL,
    quiz_name VARCHAR(255),
    quiz_type ENUM('mcq', 'scenario', 'matching', 'true_false') DEFAULT 'mcq',
    questions JSON NOT NULL, -- Array of questions with options
    passing_score INT DEFAULT 70,
    max_attempts INT DEFAULT 3,
    time_limit_minutes INT DEFAULT 0, -- 0 = no limit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    INDEX idx_lesson (lesson_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. USER LEARNING PROGRESS (Core performance-critical tables)
-- ============================================================================

-- User Course Enrollments
CREATE TABLE user_course_enrollments (
    enrollment_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL, -- FK to HUGE Auth users
    course_id VARCHAR(36) NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_track_id VARCHAR(36),
    current_lesson_id VARCHAR(36),
    completion_percentage DECIMAL(5,2) DEFAULT 0.00,
    status ENUM('not_started', 'in_progress', 'completed', 'abandoned') DEFAULT 'not_started',
    completed_at TIMESTAMP NULL,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (current_track_id) REFERENCES tracks(track_id) ON DELETE SET NULL,
    FOREIGN KEY (current_lesson_id) REFERENCES lessons(lesson_id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_user_course (user_id, course_id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_user_last_accessed (user_id, last_accessed_at DESC),
    INDEX idx_course_enrollments (course_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Lesson Progress (Optimized for resume functionality)
CREATE TABLE user_lesson_progress (
    progress_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    lesson_id VARCHAR(36) NOT NULL,
    enrollment_id VARCHAR(36) NOT NULL,
    status ENUM('not_started', 'in_progress', 'completed') DEFAULT 'not_started',
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    time_spent_seconds INT DEFAULT 0,
    completion_data JSON, -- Stores what was completed (slides, videos, etc.)
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES user_course_enrollments(enrollment_id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_user_lesson (user_id, lesson_id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_enrollment_status (enrollment_id, status),
    INDEX idx_last_accessed (user_id, last_accessed_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Quiz Attempts
CREATE TABLE user_quiz_attempts (
    attempt_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    quiz_id VARCHAR(36) NOT NULL,
    enrollment_id VARCHAR(36) NOT NULL,
    attempt_number INT DEFAULT 1,
    answers JSON NOT NULL, -- User's answers
    score DECIMAL(5,2) DEFAULT 0.00,
    passed BOOLEAN DEFAULT FALSE,
    time_taken_seconds INT DEFAULT 0,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES user_course_enrollments(enrollment_id) ON DELETE CASCADE,
    
    INDEX idx_user_quiz (user_id, quiz_id),
    INDEX idx_user_enrollment (user_id, enrollment_id),
    INDEX idx_quiz_attempts (quiz_id, attempted_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Activity Submissions (Reflections, seva tasks, etc.)
CREATE TABLE user_activity_submissions (
    submission_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    activity_id VARCHAR(36) NOT NULL,
    enrollment_id VARCHAR(36) NOT NULL,
    submission_type ENUM('text', 'audio', 'video', 'image', 'link') DEFAULT 'text',
    content JSON NOT NULL,
    status ENUM('submitted', 'reviewed', 'approved', 'rejected') DEFAULT 'submitted',
    reviewer_notes TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    
    FOREIGN KEY (activity_id) REFERENCES activities(activity_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES user_course_enrollments(enrollment_id) ON DELETE CASCADE,
    
    INDEX idx_user_activity (user_id, activity_id),
    INDEX idx_status (status, submitted_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. GAMIFICATION SYSTEM
-- ============================================================================

-- Badges Definition
CREATE TABLE badges (
    badge_id VARCHAR(36) PRIMARY KEY,
    badge_name VARCHAR(255) NOT NULL,
    badge_slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    badge_icon_url VARCHAR(500),
    badge_category ENUM('learning', 'karma', 'streak', 'social', 'seva', 'achievement') DEFAULT 'learning',
    criteria JSON NOT NULL, -- Criteria to earn the badge
    xp_reward INT DEFAULT 0,
    karma_reward INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_category (badge_category, is_active),
    INDEX idx_slug (badge_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Badges (Earned badges)
CREATE TABLE user_badges (
    user_badge_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    badge_id VARCHAR(36) NOT NULL,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    context JSON, -- What triggered the badge (course_id, lesson_id, etc.)
    
    FOREIGN KEY (badge_id) REFERENCES badges(badge_id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_user_badge (user_id, badge_id),
    INDEX idx_user_earned (user_id, earned_at DESC),
    INDEX idx_badge_users (badge_id, earned_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User XP & Karma (Consolidated metrics)
CREATE TABLE user_learning_metrics (
    user_id VARCHAR(255) PRIMARY KEY,
    total_xp INT DEFAULT 0,
    total_karma INT DEFAULT 0,
    wisdom_level INT DEFAULT 1,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    total_lessons_completed INT DEFAULT 0,
    total_courses_completed INT DEFAULT 0,
    total_time_spent_minutes INT DEFAULT 0,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_xp (total_xp DESC),
    INDEX idx_karma (total_karma DESC),
    INDEX idx_wisdom_level (wisdom_level DESC),
    INDEX idx_last_activity (last_activity_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Streaks (Daily learning streaks)
CREATE TABLE user_streaks (
    streak_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    streak_date DATE NOT NULL,
    lessons_completed INT DEFAULT 0,
    time_spent_minutes INT DEFAULT 0,
    xp_earned INT DEFAULT 0,
    
    UNIQUE KEY unique_user_date (user_id, streak_date),
    INDEX idx_user_date (user_id, streak_date DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- XP Transactions (Audit log for XP/Karma changes)
CREATE TABLE user_xp_transactions (
    transaction_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    transaction_type ENUM('xp', 'karma') DEFAULT 'xp',
    amount INT NOT NULL,
    source ENUM('lesson', 'quiz', 'activity', 'badge', 'streak', 'seva', 'manual') NOT NULL,
    source_id VARCHAR(36), -- lesson_id, badge_id, etc.
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_type (user_id, transaction_type, created_at DESC),
    INDEX idx_source (source, source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. CERTIFICATES & CREDENTIALS
-- ============================================================================

-- Certificates
CREATE TABLE certificates (
    certificate_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    course_id VARCHAR(36) NOT NULL,
    certificate_type ENUM('completion', 'mastery', 'teaching') DEFAULT 'completion',
    certificate_number VARCHAR(50) UNIQUE NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE NULL,
    certificate_url VARCHAR(500), -- PDF or image URL
    verification_code VARCHAR(100) UNIQUE,
    metadata JSON, -- Additional certificate info
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    
    INDEX idx_user_certificates (user_id, issue_date DESC),
    INDEX idx_course_certificates (course_id, issue_date DESC),
    INDEX idx_verification (verification_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. AI MENTOR & RECOMMENDATIONS
-- ============================================================================

-- AI Recommendations (Rule-based for now, LLM-ready later)
CREATE TABLE ai_recommendations (
    recommendation_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    recommendation_type ENUM('next_course', 'weak_topic', 'group', 'seva', 'badge') NOT NULL,
    target_id VARCHAR(36), -- course_id, topic_id, group_id, etc.
    priority INT DEFAULT 50, -- 0-100, higher = more important
    reason TEXT, -- Why this is recommended
    context JSON, -- Analytics data used
    is_shown BOOLEAN DEFAULT FALSE,
    is_acted_upon BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    
    INDEX idx_user_priority (user_id, is_shown, priority DESC),
    INDEX idx_user_type (user_id, recommendation_type, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Analytics (For AI/ML insights)
CREATE TABLE user_analytics (
    analytics_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value JSON NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_metric (user_id, metric_name, recorded_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. CONTENT VERSIONING & LOCALIZATION
-- ============================================================================

-- Content Versions (For A/B testing and rollback)
CREATE TABLE content_versions (
    version_id VARCHAR(36) PRIMARY KEY,
    content_type ENUM('course', 'track', 'module', 'lesson', 'quiz') NOT NULL,
    content_id VARCHAR(36) NOT NULL,
    version_number INT NOT NULL,
    content_snapshot JSON NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_content (content_type, content_id, version_number DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Localization (Multi-language support)
CREATE TABLE content_localizations (
    localization_id VARCHAR(36) PRIMARY KEY,
    content_type ENUM('course', 'track', 'module', 'lesson', 'quiz', 'badge') NOT NULL,
    content_id VARCHAR(36) NOT NULL,
    language_code VARCHAR(10) NOT NULL, -- 'en', 'hi', 'ta', etc.
    localized_content JSON NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_content_lang (content_type, content_id, language_code),
    INDEX idx_lang (language_code, is_published)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. SYSTEM TABLES
-- ============================================================================

-- Database Migrations (Track schema changes)
CREATE TABLE schema_migrations (
    migration_id VARCHAR(36) PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    version VARCHAR(20) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_version (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Feature Flags (Enable/disable features dynamically)
CREATE TABLE feature_flags (
    flag_id VARCHAR(36) PRIMARY KEY,
    flag_name VARCHAR(100) NOT NULL UNIQUE,
    is_enabled BOOLEAN DEFAULT FALSE,
    rollout_percentage INT DEFAULT 0, -- 0-100 for gradual rollout
    target_users JSON, -- Specific user_ids if needed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- INDEXING STRATEGY NOTES
-- ============================================================================
-- 
-- 1. Composite indexes prioritize most selective columns first
-- 2. User-based queries heavily indexed (user_id + timestamp patterns)
-- 3. Status columns indexed for filtering active/completed items
-- 4. Foreign keys automatically indexed by InnoDB
-- 5. JSON columns used for flexible, non-queryable data
-- 6. UNIQUE constraints prevent duplicates at DB level
-- 7. Timestamps indexed for pagination and recent activity queries
-- 
-- ============================================================================

-- Insert initial migration record
INSERT INTO schema_migrations (migration_id, migration_name, version)
VALUES (UUID(), 'initial_schema', '1.0.0');



