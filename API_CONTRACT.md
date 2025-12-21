# HUGE Learning Platform - Secure API Contract

## Overview

This document defines the API contract between the Flutter app and backend services, ensuring secure user authentication and zero-duplicate users.

## Architecture

- **HUGE Foundations Auth API**: Source of truth for user authentication
- **Learning Platform API**: Manages learning-specific data with user mapping

## Base URLs

```
HUGE Auth: https://huge.imedhya.com/api/auth
Learning Platform: https://huge.imedhya.com/api/learning
```

## Database Information

### HUGE Foundations Auth Database
- **Type**: MySQL
- **Host**: huge.imedhya.com:3306
- **Database**: cltlsyxm_huge
- **Purpose**: User authentication (Source of Truth)
- **Access**: Through API only, NEVER expose credentials to Flutter app

### Learning Platform Database
- **Type**: MySQL (recommended) or PostgreSQL
- **Database**: huge_learning_platform (create separately)
- **Purpose**: Learning-specific data
- **Access**: Through Learning Platform API

---

## 1. HUGE Foundations Auth API (Existing)

### 1.1 Login

**Endpoint**: `POST /api/auth/login`

**Description**: Authenticate user with email and password

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "user_abc123def456",
    "email": "user@example.com",
    "name": "John Doe",
    "avatar_url": "https://cdn.example.com/avatars/user123.jpg",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: Invalid request format
- `429 Too Many Requests`: Rate limit exceeded

### 1.2 Register

**Endpoint**: `POST /api/auth/register`

**Description**: Create new user account

**Request**:
```json
{
  "email": "newuser@example.com",
  "password": "SecurePass123!",
  "name": "Jane Doe"
}
```

**Response** (201 Created):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "user_newid789",
    "email": "newuser@example.com",
    "name": "Jane Doe",
    "created_at": "2024-01-15T12:00:00Z"
  }
}
```

**Error Responses**:
- `409 Conflict`: Email already exists
- `400 Bad Request`: Invalid request format or weak password

### 1.3 Refresh Token

**Endpoint**: `POST /api/auth/refresh`

**Description**: Get new access token using refresh token

**Request**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired refresh token

### 1.4 Logout

**Endpoint**: `POST /api/auth/logout`

**Description**: Invalidate user session

**Request Headers**:
```
Authorization: Bearer {access_token}
```

**Request**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response** (200 OK):
```json
{
  "message": "Logout successful"
}
```

### 1.5 Verify Token

**Endpoint**: `GET /api/auth/verify`

**Description**: Verify token validity

**Request Headers**:
```
Authorization: Bearer {access_token}
```

**Response** (200 OK):
```json
{
  "valid": true,
  "user_id": "user_abc123def456",
  "expires_at": "2024-01-15T13:00:00Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired token

---

## 2. Learning Platform API (New)

### 2.1 Get or Create Learning Profile

**Endpoint**: `GET /api/learning/profile/me`

**Description**: Get learning profile for current user. Auto-creates if doesn't exist (idempotent).

**Request Headers**:
```
Authorization: Bearer {access_token}
```

**Response** (200 OK - Existing Profile):
```json
{
  "learning_profile_id": "lp_789xyz",
  "user_id": "user_abc123def456",
  "display_name": "John Doe",
  "preferences": {
    "language": "en",
    "notifications_enabled": true,
    "theme": "light"
  },
  "onboarding_completed": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-14T10:00:00Z",
  "is_new": false
}
```

**Response** (201 Created - New Profile):
```json
{
  "learning_profile_id": "lp_new456",
  "user_id": "user_abc123def456",
  "display_name": "John Doe",
  "preferences": {},
  "onboarding_completed": false,
  "created_at": "2024-01-15T12:00:00Z",
  "updated_at": "2024-01-15T12:00:00Z",
  "is_new": true
}
```

**Implementation Notes**:
- Server extracts `user_id` from JWT token
- Uses `INSERT ... ON CONFLICT` to ensure idempotency
- No duplicate profiles possible due to UNIQUE constraint
- Auto-creates profile with default preferences

**Error Responses**:
- `401 Unauthorized`: Invalid or expired token
- `500 Internal Server Error`: Database error

### 2.2 Update Learning Profile

**Endpoint**: `PUT /api/learning/profile/me`

**Description**: Update learning profile preferences

**Request Headers**:
```
Authorization: Bearer {access_token}
```

**Request**:
```json
{
  "preferences": {
    "language": "hi",
    "notifications_enabled": false,
    "theme": "dark"
  },
  "onboarding_completed": true
}
```

**Response** (200 OK):
```json
{
  "learning_profile_id": "lp_789xyz",
  "user_id": "user_abc123def456",
  "display_name": "John Doe",
  "preferences": {
    "language": "hi",
    "notifications_enabled": false,
    "theme": "dark"
  },
  "onboarding_completed": true,
  "updated_at": "2024-01-15T12:30:00Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid token
- `404 Not Found`: Learning profile doesn't exist
- `400 Bad Request`: Invalid request format

### 2.3 Get Learning Progress

**Endpoint**: `GET /api/learning/progress`

**Description**: Get user's learning progress across all courses

**Request Headers**:
```
Authorization: Bearer {access_token}
```

**Query Parameters**:
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)

**Response** (200 OK):
```json
{
  "progress": [
    {
      "progress_id": "prog_123",
      "course_id": "course_vedas_101",
      "course_name": "Introduction to Vedas",
      "progress_percentage": 75,
      "last_accessed_at": "2024-01-14T10:00:00Z",
      "completed_at": null,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-14T10:00:00Z"
    },
    {
      "progress_id": "prog_124",
      "course_id": "course_bhagavad_gita",
      "course_name": "Bhagavad Gita Study",
      "progress_percentage": 100,
      "last_accessed_at": "2024-01-10T15:00:00Z",
      "completed_at": "2024-01-10T15:00:00Z",
      "created_at": "2023-12-15T00:00:00Z",
      "updated_at": "2024-01-10T15:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_items": 2,
    "items_per_page": 20
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid token

### 2.4 Update Learning Progress

**Endpoint**: `PUT /api/learning/progress/{course_id}`

**Description**: Update progress for a specific course

**Request Headers**:
```
Authorization: Bearer {access_token}
```

**Request**:
```json
{
  "progress_percentage": 85,
  "last_accessed_at": "2024-01-15T12:00:00Z"
}
```

**Response** (200 OK):
```json
{
  "progress_id": "prog_123",
  "course_id": "course_vedas_101",
  "progress_percentage": 85,
  "last_accessed_at": "2024-01-15T12:00:00Z",
  "updated_at": "2024-01-15T12:00:00Z"
}
```

---

## Security Requirements

### 1. Authentication

- **Token Type**: JWT (recommended) or OAuth 2.0
- **Token Storage**: Secure storage on device (flutter_secure_storage)
- **Token Transmission**: HTTPS only, Authorization header
- **Token Expiration**: Access token: 1 hour, Refresh token: 30 days

### 2. Authorization

- **Access Control**: Bearer token in Authorization header
- **Scope**: Learning Platform API validates token with HUGE Auth
- **User Context**: Extract user_id from token claims

### 3. Token Validation

JWT token structure (if using JWT):
```
Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "sub": "user_abc123def456",  // user_id
  "email": "user@example.com",
  "name": "John Doe",
  "iat": 1705320000,           // issued at
  "exp": 1705323600            // expires at
}
```

### 4. Error Handling

- **Token Expired**: Return 401, client should refresh
- **Invalid Token**: Return 401, client should logout
- **Network Error**: Client fallback to cached data

---

## Rate Limiting

- **Auth endpoints**: 10 requests per minute per IP
- **Learning endpoints**: 60 requests per minute per user

---

## CORS Configuration

```
Access-Control-Allow-Origin: https://app.hugefoundations.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
Access-Control-Max-Age: 3600
```

---

## Database Schema (Learning Platform)

**Note**: Use MySQL syntax (compatible with HUGE Foundations infrastructure)

```sql
-- Create Learning Platform Database (separate from auth DB)
CREATE DATABASE IF NOT EXISTS huge_learning_platform
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE huge_learning_platform;

-- Learning Profiles Table (User Mapping Layer)
CREATE TABLE learning_profiles (
    learning_profile_id VARCHAR(36) PRIMARY KEY,  -- UUID as VARCHAR
    user_id VARCHAR(255) NOT NULL UNIQUE,  -- FK to HUGE Auth users table
    display_name VARCHAR(255),
    preferences JSON,  -- MySQL JSON type
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    UNIQUE KEY unique_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Learning Progress Table
CREATE TABLE learning_progress (
    progress_id VARCHAR(36) PRIMARY KEY,  -- UUID as VARCHAR
    learning_profile_id VARCHAR(36) NOT NULL,
    course_id VARCHAR(255) NOT NULL,
    progress_percentage INT DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    last_accessed_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (learning_profile_id) 
        REFERENCES learning_profiles(learning_profile_id) 
        ON DELETE CASCADE,
    INDEX idx_learning_profile_id (learning_profile_id),
    INDEX idx_course_id (course_id),
    UNIQUE KEY unique_profile_course (learning_profile_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Zero Duplicate Users Strategy

1. **Unique Constraint**: `user_id` has UNIQUE constraint
2. **Upsert Logic**: Server uses `INSERT ... ON CONFLICT DO NOTHING`
3. **Idempotent API**: GET /profile/me is idempotent (safe to call multiple times)
4. **Atomic Operations**: Profile creation is atomic
5. **Foreign Key**: `user_id` references HUGE Auth user (conceptual FK)

---

## Example Implementation (Server-side)

```javascript
// Node.js/Express example
app.get('/api/learning/profile/me', authenticateToken, async (req, res) => {
  const userId = req.user.id; // Extracted from JWT
  
  try {
    // Upsert: Get or create
    const profile = await db.query(`
      INSERT INTO learning_profiles (user_id, display_name)
      VALUES ($1, $2)
      ON CONFLICT (user_id)
      DO UPDATE SET updated_at = CURRENT_TIMESTAMP
      RETURNING *, 
                (xmax = 0) AS is_new  -- xmax = 0 means it was inserted
    `, [userId, req.user.name]);
    
    res.json(profile.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to get/create profile' });
  }
});
```

---

## Testing Checklist

- [ ] Test login with valid credentials
- [ ] Test login with invalid credentials
- [ ] Test token refresh before expiration
- [ ] Test token refresh after expiration
- [ ] Test auto-create learning profile on first login
- [ ] Test prevent duplicate profiles (call twice)
- [ ] Test update learning profile
- [ ] Test logout (clear tokens)
- [ ] Test offline fallback (cached data)
- [ ] Test network error handling
- [ ] Test token expiration (no crash)
- [ ] Test rate limiting
- [ ] Test CORS headers

---

## Monitoring & Logging

- Log all authentication attempts (success/failure)
- Log token refresh attempts
- Log learning profile creations
- Monitor duplicate prevention (should be 0)
- Alert on high token refresh failure rate
- Track API response times

---

## Compliance

- **GDPR**: User data minimization, right to erasure
- **Privacy**: Encrypt sensitive data at rest and in transit
- **Security**: Regular security audits, penetration testing

