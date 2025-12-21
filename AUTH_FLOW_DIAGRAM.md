# HUGE Learning Platform - Authentication Flow

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    HUGE Learning Platform App                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Login/Register
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│               HUGE Foundations Auth Service                      │
│                   (Source of Truth)                              │
│  - User Authentication (JWT/OAuth/Session)                       │
│  - Token Generation                                              │
│  - User Identity Management                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Returns: access_token, refresh_token, user_id
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  User Mapping Layer (Flutter)                    │
│  - Detect token type (JWT/OAuth/Session)                         │
│  - Store tokens securely (Local Storage)                         │
│  - Map HUGE user_id → Learning Profile                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Check Learning Profile
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Learning Platform Database & API                    │
│  - learning_profiles table:                                      │
│    • learning_profile_id (PK)                                    │
│    • user_id (FK → HUGE Auth user_id) UNIQUE                    │
│    • preferences (JSON)                                          │
│    • created_at                                                  │
│    • updated_at                                                  │
│  - learning_progress table:                                      │
│    • progress_id (PK)                                            │
│    • learning_profile_id (FK)                                    │
│    • course_id                                                   │
│    • progress_percentage                                         │
│    • completed_at                                                │
└─────────────────────────────────────────────────────────────────┘
```

## Authentication Flow Sequence

### 1. First-Time Login Flow

```
User → Login Screen → HUGE Auth API
                          │
                          ├─ Validates credentials
                          ├─ Returns: access_token, refresh_token, user_id
                          │
                          ▼
                    Flutter App
                          │
                          ├─ Store tokens securely
                          ├─ Detect token type (JWT/OAuth)
                          │
                          ▼
                Learning Platform API
                          │
                          ├─ Check if learning_profile exists (user_id)
                          │
                          ├─ NO → Auto-create learning_profile
                          │        • learning_profile_id = UUID
                          │        • user_id = HUGE user_id
                          │        • preferences = default
                          │
                          ├─ YES → Load existing profile
                          │
                          ▼
                    Home Screen
```

### 2. Subsequent Login Flow (Token Exists)

```
App Launch → Check Stored Token
                    │
                    ├─ Token Valid?
                    │
                    ├─ YES → Silent Refresh (if near expiry)
                    │         │
                    │         ├─ Refresh Token Valid?
                    │         │
                    │         ├─ YES → Get new access_token
                    │         │        Load learning profile
                    │         │        → Home Screen
                    │         │
                    │         └─ NO → Logout → Login Screen
                    │
                    └─ NO → Check Refresh Token
                              │
                              ├─ Valid → Refresh access_token
                              │          → Home Screen
                              │
                              └─ Invalid → Logout → Login Screen
```

### 3. Silent Token Refresh Flow

```
API Request → Interceptor Checks Token
                    │
                    ├─ Token expires in < 5 minutes?
                    │
                    ├─ YES → Trigger Silent Refresh
                    │         │
                    │         ├─ Call HUGE Auth /refresh endpoint
                    │         ├─ Get new access_token
                    │         ├─ Update stored token
                    │         ├─ Retry original request
                    │         │
                    │         └─ Refresh Failed?
                    │              └─ Logout user
                    │
                    └─ NO → Continue request
```

### 4. Token Expiration Handling

```
API Request → 401 Unauthorized
                    │
                    ├─ Attempt Token Refresh
                    │
                    ├─ Refresh Successful?
                    │   │
                    │   ├─ YES → Retry original request
                    │   │
                    │   └─ NO → Graceful Logout
                    │            │
                    │            ├─ Clear local tokens
                    │            ├─ Clear learning profile cache
                    │            ├─ Show logout message
                    │            └─ Redirect to Login
                    │
                    └─ Network Failure?
                         │
                         └─ Use Cached Data (Offline Mode)
```

### 5. Logout Flow

```
User Clicks Logout → Flutter App
                          │
                          ├─ Call HUGE Auth /logout (if online)
                          │   │
                          │   └─ Invalidate server-side session
                          │
                          ├─ Clear Local Storage
                          │   ├─ Remove access_token
                          │   ├─ Remove refresh_token
                          │   ├─ Remove user_id
                          │   └─ Clear cached learning profile
                          │
                          ├─ Clear API Client tokens
                          │
                          └─ Redirect to Login Screen
```

## Token Type Detection

```dart
Token Detection Logic:
1. Check token format:
   - JWT: Contains 3 parts separated by dots (header.payload.signature)
   - OAuth: Usually starts with "Bearer" and has specific format
   - Session: Session ID string

2. Decode token (if JWT):
   - Extract expiration time (exp claim)
   - Extract user information
   - Validate signature (client-side validation)

3. Store token metadata:
   - token_type: "JWT" | "OAuth" | "Session"
   - expires_at: Timestamp
   - issued_at: Timestamp
```

## Security Measures

### 1. Token Storage
- **Secure Storage**: Use `flutter_secure_storage` for tokens
- **Encryption**: Encrypt sensitive data at rest
- **No Plaintext**: Never store tokens in SharedPreferences as plaintext

### 2. Token Transmission
- **HTTPS Only**: All API calls over HTTPS
- **Authorization Header**: Bearer token in header
- **No URL Parameters**: Never pass tokens in URLs

### 3. Token Refresh
- **Refresh Before Expiry**: Refresh 5 minutes before expiration
- **Single Refresh Request**: Prevent multiple simultaneous refreshes
- **Refresh Token Rotation**: Support refresh token rotation if API provides

### 4. Error Handling
- **Graceful Degradation**: Fall back to cached data on network failure
- **User Feedback**: Clear error messages without exposing security details
- **Retry Logic**: Exponential backoff for transient failures

## Database Schema

### Learning Platform Database

```sql
-- Learning Profiles Table (NO user credentials, only mapping)
CREATE TABLE learning_profiles (
    learning_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL UNIQUE,  -- Foreign key to HUGE Auth user
    display_name VARCHAR(255),
    preferences JSONB DEFAULT '{}',
    onboarding_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_user_id UNIQUE (user_id)
);

-- Index for fast lookups
CREATE INDEX idx_learning_profiles_user_id ON learning_profiles(user_id);

-- Learning Progress Table
CREATE TABLE learning_progress (
    progress_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learning_profile_id UUID NOT NULL REFERENCES learning_profiles(learning_profile_id) ON DELETE CASCADE,
    course_id VARCHAR(255) NOT NULL,
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    last_accessed_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_profile_course UNIQUE (learning_profile_id, course_id)
);

-- Index for queries
CREATE INDEX idx_learning_progress_profile ON learning_progress(learning_profile_id);
CREATE INDEX idx_learning_progress_course ON learning_progress(course_id);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_learning_profiles_updated_at 
    BEFORE UPDATE ON learning_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_learning_progress_updated_at 
    BEFORE UPDATE ON learning_progress 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## API Contract

### HUGE Foundations Auth API (Existing)

#### POST /api/auth/login
```json
Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "user_123456",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### POST /api/auth/refresh
```json
Request:
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_in": 3600
}
```

#### POST /api/auth/logout
```json
Request:
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}

Response:
{
  "message": "Logout successful"
}
```

### Learning Platform API (New)

#### GET /api/learning/profile/me
**Description**: Get or auto-create learning profile for current user

```json
Request Headers:
Authorization: Bearer {access_token}

Response (Existing Profile):
{
  "learning_profile_id": "profile_789",
  "user_id": "user_123456",
  "display_name": "John Doe",
  "preferences": {
    "language": "en",
    "notifications_enabled": true
  },
  "onboarding_completed": true,
  "created_at": "2024-01-01T00:00:00Z"
}

Response (Auto-Created Profile):
{
  "learning_profile_id": "profile_new",
  "user_id": "user_123456",
  "display_name": "John Doe",
  "preferences": {},
  "onboarding_completed": false,
  "created_at": "2024-01-15T00:00:00Z",
  "is_new": true
}
```

#### PUT /api/learning/profile/me
**Description**: Update learning profile preferences

```json
Request:
{
  "preferences": {
    "language": "hi",
    "notifications_enabled": false
  },
  "onboarding_completed": true
}

Response:
{
  "learning_profile_id": "profile_789",
  "user_id": "user_123456",
  "preferences": {
    "language": "hi",
    "notifications_enabled": false
  },
  "onboarding_completed": true,
  "updated_at": "2024-01-15T12:00:00Z"
}
```

#### GET /api/learning/progress
**Description**: Get user's learning progress

```json
Request Headers:
Authorization: Bearer {access_token}

Response:
{
  "progress": [
    {
      "course_id": "course_101",
      "progress_percentage": 75,
      "last_accessed_at": "2024-01-14T10:00:00Z",
      "completed_at": null
    }
  ]
}
```

## Zero Duplicate Users Strategy

1. **Unique Constraint**: `user_id` in `learning_profiles` table has UNIQUE constraint
2. **Upsert Logic**: Use "INSERT ... ON CONFLICT" to prevent duplicates
3. **Server-Side Check**: Learning Platform API validates user_id uniqueness
4. **Idempotent Operations**: Creating learning profile is idempotent

```sql
-- Example upsert query
INSERT INTO learning_profiles (user_id, display_name, preferences)
VALUES ($1, $2, $3)
ON CONFLICT (user_id) 
DO UPDATE SET 
    display_name = EXCLUDED.display_name,
    updated_at = CURRENT_TIMESTAMP
RETURNING *;
```

## Network Failure Fallback Strategy

1. **Offline Data**: Cache learning profile and progress locally
2. **Retry Logic**: Exponential backoff for failed requests
3. **Queue Sync**: Queue operations when offline, sync when online
4. **User Feedback**: Show offline indicator, explain limitations
5. **Graceful Degradation**: Allow read-only access to cached data



