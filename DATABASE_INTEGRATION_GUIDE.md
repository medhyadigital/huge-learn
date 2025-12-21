# HUGE Foundations Database Integration Guide

## Database Architecture

### HUGE Foundations Auth Database (Existing)
- **Type**: MySQL
- **Host**: huge.imedhya.com:3306
- **Database**: cltlsyxm_huge
- **Purpose**: User authentication (Source of Truth)
- **Access**: Read-only from Learning Platform

### Learning Platform Database (New - Separate)
- **Type**: MySQL (recommended for consistency) or PostgreSQL
- **Purpose**: Learning-specific data (profiles, progress, courses)
- **Relationship**: References HUGE Auth users by `user_id`

---

## ⚠️ Security Guidelines

### 1. Credential Management

**NEVER commit credentials to version control!**

```bash
# Create .env file (already in .gitignore)
cp .env.example .env

# Edit .env with actual credentials
nano .env
```

### 2. Environment Variables

Use environment variables for all sensitive data:

```bash
# .env file (DO NOT COMMIT)
DATABASE_URL="mysql://cltlsyxm_huge_db_admin:Huge%231Foundations@huge.imedhya.com:3306/cltlsyxm_huge?connection_limit=15&pool_timeout=20&connect_timeout=10"
NEXTAUTH_SECRET="vmndMMUsP5yL5UI1KH+uT+wIJb3QCTIdOmh32GeyopI="
```

### 3. Backend Access Control

```javascript
// IMPORTANT: Learning Platform should NOT have direct MySQL credentials
// Instead, create secure API endpoints in HUGE Foundations backend

// Good: API endpoint
GET /api/auth/validate-token
POST /api/auth/get-user-info

// Bad: Direct MySQL access from Learning Platform
// NEVER expose MySQL credentials to Learning Platform API
```

---

## Database Schema

### HUGE Foundations Auth DB (Existing)

**Users Table** (Read-only access):
```sql
-- This table already exists in cltlsyxm_huge database
-- Learning Platform should NOT modify this table
-- Access only through HUGE Foundations Auth API

-- Example structure (verify actual schema):
users (
  id VARCHAR(255) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  password_hash VARCHAR(255),  -- NEVER expose this
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### Learning Platform DB (New - Create This)

**Create separate database for Learning Platform**:

```sql
-- Option 1: Create in same MySQL server (different database)
CREATE DATABASE huge_learning_platform;

-- Option 2: Use separate MySQL/PostgreSQL server (recommended)
-- Host on different server for security isolation
```

**Learning Profiles Table**:
```sql
CREATE TABLE learning_profiles (
    learning_profile_id VARCHAR(36) PRIMARY KEY,  -- UUID
    user_id VARCHAR(255) NOT NULL UNIQUE,  -- FK to HUGE Auth (conceptual)
    display_name VARCHAR(255),
    preferences JSON,  -- MySQL JSON type
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    UNIQUE KEY unique_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Learning Progress Table**:
```sql
CREATE TABLE learning_progress (
    progress_id VARCHAR(36) PRIMARY KEY,  -- UUID
    learning_profile_id VARCHAR(36) NOT NULL,
    course_id VARCHAR(255) NOT NULL,
    progress_percentage INT DEFAULT 0 CHECK (progress_percentage BETWEEN 0 AND 100),
    last_accessed_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (learning_profile_id) REFERENCES learning_profiles(learning_profile_id) ON DELETE CASCADE,
    INDEX idx_learning_profile_id (learning_profile_id),
    INDEX idx_course_id (course_id),
    UNIQUE KEY unique_profile_course (learning_profile_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Backend Integration Architecture

### Option 1: Extend HUGE Foundations Backend (Recommended)

Add Learning Platform endpoints to existing HUGE Foundations backend:

```javascript
// In HUGE Foundations backend (has MySQL access)

// Middleware to validate JWT token
const authenticateToken = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  try {
    const decoded = jwt.verify(token, process.env.NEXTAUTH_SECRET);
    req.user = decoded; // Contains user_id
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Learning Profile endpoints
app.get('/api/learning/profile/me', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  
  try {
    // Upsert: Get or create learning profile
    const [profile] = await learningDb.query(`
      INSERT INTO learning_profiles (learning_profile_id, user_id, display_name)
      VALUES (UUID(), ?, ?)
      ON DUPLICATE KEY UPDATE 
        updated_at = CURRENT_TIMESTAMP,
        learning_profile_id = LAST_INSERT_ID(learning_profile_id)
      RETURNING *
    `, [userId, req.user.name]);
    
    const isNew = profile.created_at === profile.updated_at;
    
    res.json({
      ...profile,
      is_new: isNew
    });
  } catch (error) {
    console.error('Profile creation error:', error);
    res.status(500).json({ error: 'Failed to get/create profile' });
  }
});

app.put('/api/learning/profile/me', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { preferences, onboarding_completed } = req.body;
  
  try {
    const [profile] = await learningDb.query(`
      UPDATE learning_profiles
      SET 
        preferences = ?,
        onboarding_completed = ?,
        updated_at = CURRENT_TIMESTAMP
      WHERE user_id = ?
      RETURNING *
    `, [JSON.stringify(preferences), onboarding_completed, userId]);
    
    res.json(profile);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
});
```

### Option 2: Separate Learning Platform Backend

Create a separate backend that calls HUGE Auth API for validation:

```javascript
// Learning Platform backend (no direct MySQL access to HUGE Auth)

const validateWithHugeAuth = async (token) => {
  const response = await axios.get('https://huge.imedhya.com/api/auth/verify', {
    headers: { Authorization: `Bearer ${token}` }
  });
  return response.data; // Contains user_id
};

app.get('/api/learning/profile/me', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  try {
    // Validate token with HUGE Auth
    const user = await validateWithHugeAuth(token);
    
    // Now create/get learning profile
    // ... rest of logic
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});
```

---

## Connection Configuration

### Node.js/Express Example

```javascript
// Install dependencies
// npm install mysql2 dotenv

const mysql = require('mysql2/promise');
require('dotenv').config();

// HUGE Auth DB (read-only, if direct access needed)
const authDb = mysql.createPool({
  uri: process.env.DATABASE_URL,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Learning Platform DB (separate database)
const learningDb = mysql.createPool({
  host: 'your-learning-db-host',
  user: 'learning_db_user',
  password: 'learning_db_password',
  database: 'huge_learning_platform',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test connection
authDb.query('SELECT 1')
  .then(() => console.log('Auth DB connected'))
  .catch(err => console.error('Auth DB connection failed:', err));

learningDb.query('SELECT 1')
  .then(() => console.log('Learning DB connected'))
  .catch(err => console.error('Learning DB connection failed:', err));
```

---

## Security Best Practices

### 1. Database Access

```javascript
// ✅ GOOD: API-based access
Flutter App → HUGE Auth API → MySQL (Auth)
Flutter App → Learning API → MySQL (Learning)

// ❌ BAD: Direct database access from Flutter
Flutter App → MySQL (NEVER expose credentials to mobile app)
```

### 2. Password Security

```javascript
// NEVER expose password fields from users table
const getUserInfo = async (userId) => {
  const [user] = await authDb.query(`
    SELECT id, email, name, created_at
    -- Note: NO password_hash field
    FROM users
    WHERE id = ?
  `, [userId]);
  
  return user;
};
```

### 3. Token Validation

```javascript
// Always validate tokens server-side
const jwt = require('jsonwebtoken');

const validateToken = (token) => {
  try {
    const decoded = jwt.verify(token, process.env.NEXTAUTH_SECRET);
    return decoded;
  } catch (error) {
    throw new Error('Invalid token');
  }
};
```

### 4. SQL Injection Prevention

```javascript
// ✅ GOOD: Parameterized queries
await db.query('SELECT * FROM users WHERE id = ?', [userId]);

// ❌ BAD: String concatenation
await db.query(`SELECT * FROM users WHERE id = '${userId}'`);
```

---

## Flutter App Configuration

### Update Constants

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  // API Endpoints (update based on your deployment)
  static const String hugeFoundationsAuthBaseUrl = 
    'https://huge.imedhya.com/api/auth';
  static const String learningPlatformBaseUrl = 
    'https://huge.imedhya.com/api/learning';
}
```

### API Client Configuration

```dart
// Learning Platform API will validate tokens with HUGE Auth
// No database credentials needed in Flutter app
final apiClient = ApiClient(
  baseUrl: AppConstants.learningPlatformBaseUrl,
  authToken: storedAccessToken,
);
```

---

## Testing Checklist

### 1. Authentication
- [ ] Login with valid HUGE Foundations credentials
- [ ] Token is returned and stored securely
- [ ] Token is validated by backend

### 2. Learning Profile
- [ ] Auto-create profile on first login
- [ ] Profile is linked to correct user_id
- [ ] No duplicate profiles created
- [ ] Preferences can be updated

### 3. Security
- [ ] Database credentials not exposed in Flutter app
- [ ] Tokens transmitted over HTTPS only
- [ ] SQL injection prevention verified
- [ ] Password fields never exposed

### 4. Error Handling
- [ ] Invalid token handled gracefully
- [ ] Database connection errors handled
- [ ] Network failures have fallbacks

---

## Deployment Steps

### 1. Create Learning Platform Database

```sql
-- On MySQL server (can be same server, different DB)
CREATE DATABASE huge_learning_platform
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Create database user (separate from auth DB)
CREATE USER 'learning_db_admin'@'%' IDENTIFIED BY 'secure-password';
GRANT ALL PRIVILEGES ON huge_learning_platform.* TO 'learning_db_admin'@'%';
FLUSH PRIVILEGES;
```

### 2. Run Migrations

```sql
-- Run the CREATE TABLE statements from above
USE huge_learning_platform;
-- Execute learning_profiles and learning_progress tables
```

### 3. Deploy Backend

```bash
# Set environment variables
export DATABASE_URL="mysql://..."
export NEXTAUTH_SECRET="..."
export LEARNING_DB_URL="mysql://learning_db_admin:password@host/huge_learning_platform"

# Start server
npm start
```

### 4. Test Integration

```bash
# Test auth endpoint
curl -X POST https://huge.imedhya.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test learning profile endpoint
curl https://huge.imedhya.com/api/learning/profile/me \
  -H "Authorization: Bearer {token}"
```

---

## Support

For issues with:
- **HUGE Auth Database**: Contact HUGE Foundations DB admin
- **Learning Platform**: Contact Learning Platform team
- **Integration**: Review this guide and API_CONTRACT.md

---

## Important Notes

1. **Never commit** database credentials to Git
2. **Use environment variables** for all sensitive data
3. **Separate databases** for Auth and Learning Platform
4. **API-based access only** from Flutter app
5. **Validate tokens server-side** always
6. **MySQL-compatible** syntax for queries
7. **Connection pooling** for performance
8. **Backup strategy** for Learning Platform DB



