# HUGE Learning Platform - Quick Start Guide

## 🚀 Getting Started with HUGE Foundations Database

You've provided the HUGE Foundations MySQL database credentials. Here's how to integrate them securely.

---

## ⚠️ CRITICAL: Security First

**The credentials you provided are for PRODUCTION use. Handle with extreme care!**

```
Database: MySQL at huge.imedhya.com:3306
Database Name: cltlsyxm_huge
Purpose: HUGE Foundations User Authentication
```

---

## Step 1: Secure Your Credentials

### Create .env file (NEVER commit this)

```bash
# Create .env file
cd "D:\Web Dev\HUGE_Learning"
cp .env.example .env

# Edit .env with actual credentials
# Add these lines to .env:
```

```bash
# .env file (DO NOT COMMIT)
DATABASE_URL="mysql://cltlsyxm_huge_db_admin:Huge%231Foundations@huge.imedhya.com:3306/cltlsyxm_huge?connection_limit=15&pool_timeout=20&connect_timeout=10"
NEXTAUTH_SECRET="vmndMMUsP5yL5UI1KH+uT+wIJb3QCTIdOmh32GeyopI="
```

### Verify .gitignore

```bash
# Check that .env is in .gitignore
cat .gitignore | grep ".env"

# Should see:
# .env
# .env.local
# .env.production
# .env.development
```

---

## Step 2: Set Up Learning Platform Database

You need a **SEPARATE** database for Learning Platform data.

### Option A: Create on Same MySQL Server (Recommended)

```sql
-- Connect to MySQL server
mysql -h huge.imedhya.com -P 3306 -u cltlsyxm_huge_db_admin -p

-- Create new database for Learning Platform
CREATE DATABASE IF NOT EXISTS huge_learning_platform
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Create tables
USE huge_learning_platform;

-- Learning Profiles Table
CREATE TABLE learning_profiles (
    learning_profile_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255),
    preferences JSON,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    UNIQUE KEY unique_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Learning Progress Table
CREATE TABLE learning_progress (
    progress_id VARCHAR(36) PRIMARY KEY,
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

## Step 3: Backend API Implementation

### Install Dependencies

```bash
npm install express mysql2 jsonwebtoken dotenv cors
```

### Create Backend Server

```javascript
// server.js
const express = require('express');
const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(require('cors')());

// Database connections
const authDb = mysql.createPool({
  uri: process.env.DATABASE_URL,
  waitForConnections: true,
  connectionLimit: 10,
});

const learningDb = mysql.createPool({
  host: 'huge.imedhya.com',
  port: 3306,
  user: 'cltlsyxm_huge_db_admin',
  password: 'Huge#1Foundations',
  database: 'huge_learning_platform',
  waitForConnections: true,
  connectionLimit: 10,
});

// Middleware to validate JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.NEXTAUTH_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Query HUGE Auth database
    const [users] = await authDb.query(
      'SELECT id, email, name, password_hash FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    
    // TODO: Verify password hash (use bcrypt)
    // const isValid = await bcrypt.compare(password, user.password_hash);
    
    // For now, generate token (IMPLEMENT PASSWORD VERIFICATION!)
    const accessToken = jwt.sign(
      { id: user.id, email: user.email, name: user.name },
      process.env.NEXTAUTH_SECRET,
      { expiresIn: '1h' }
    );

    const refreshToken = jwt.sign(
      { id: user.id },
      process.env.NEXTAUTH_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get or create learning profile
app.get('/api/learning/profile/me', authenticateToken, async (req, res) => {
  const userId = req.user.id;

  try {
    // Check if profile exists
    const [existing] = await learningDb.query(
      'SELECT * FROM learning_profiles WHERE user_id = ?',
      [userId]
    );

    if (existing.length > 0) {
      return res.json({
        ...existing[0],
        is_new: false
      });
    }

    // Create new profile
    const profileId = require('crypto').randomUUID();
    await learningDb.query(
      `INSERT INTO learning_profiles 
       (learning_profile_id, user_id, display_name) 
       VALUES (?, ?, ?)`,
      [profileId, userId, req.user.name]
    );

    const [newProfile] = await learningDb.query(
      'SELECT * FROM learning_profiles WHERE learning_profile_id = ?',
      [profileId]
    );

    res.status(201).json({
      ...newProfile[0],
      is_new: true
    });
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ error: 'Failed to get/create profile' });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## Step 4: Update Flutter App Configuration

### Update Constants

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  // Update these to your deployed backend URL
  static const String hugeFoundationsAuthBaseUrl = 
    'http://your-backend-url:3000/api/auth';
  static const String learningPlatformBaseUrl = 
    'http://your-backend-url:3000/api/learning';
}
```

---

## Step 5: Test the Integration

### Test Backend

```bash
# Start backend server
node server.js

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test learning profile (use token from above)
curl http://localhost:3000/api/learning/profile/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Test Flutter App

```bash
# Run Flutter app
cd "D:\Web Dev\HUGE_Learning"
flutter run

# Test login from app
# Should create learning profile automatically
```

---

## 🔐 Security Reminders

### DO

✅ Keep `.env` file out of version control  
✅ Use HTTPS in production  
✅ Implement proper password hashing (bcrypt)  
✅ Validate all inputs  
✅ Use parameterized queries  
✅ Implement rate limiting  
✅ Monitor access logs  

### DON'T

❌ Commit database credentials to Git  
❌ Expose credentials in Flutter app  
❌ Use HTTP in production  
❌ Store passwords in plain text  
❌ Skip input validation  
❌ Use string concatenation for SQL  

---

## Common Issues & Solutions

### Issue 1: Can't Connect to MySQL

```bash
# Check if MySQL port is accessible
telnet huge.imedhya.com 3306

# Check credentials
mysql -h huge.imedhya.com -P 3306 -u cltlsyxm_huge_db_admin -p
```

### Issue 2: "ECONNREFUSED" Error

- Check if backend server is running
- Verify firewall settings
- Check if MySQL allows remote connections

### Issue 3: "Invalid Token" Error

- Verify NEXTAUTH_SECRET matches between backend and token generation
- Check token expiration
- Ensure Authorization header format: "Bearer {token}"

### Issue 4: "Duplicate Entry" Error

- This is GOOD! It means the UNIQUE constraint is working
- Profile already exists for this user_id
- Use GET endpoint instead of trying to create again

---

## Next Steps

1. ✅ Secure credentials in .env
2. ✅ Create learning_platform database
3. ✅ Deploy backend API
4. ✅ Test authentication flow
5. ✅ Test learning profile creation
6. ⏭️ Implement password hashing
7. ⏭️ Add HTTPS/SSL
8. ⏭️ Set up monitoring
9. ⏭️ Deploy to production

---

## Support & Resources

- **Database Integration Guide**: `DATABASE_INTEGRATION_GUIDE.md`
- **API Contract**: `API_CONTRACT.md`
- **Security Checklist**: `SECURITY_CHECKLIST.md`
- **Auth Flow Diagram**: `AUTH_FLOW_DIAGRAM.md`

---

## Important Notes

1. **Password Hashing**: The example above needs proper password verification with bcrypt
2. **Production URLs**: Update API URLs when deploying
3. **HTTPS**: Always use HTTPS in production
4. **Backups**: Set up regular backups for learning_platform database
5. **Monitoring**: Implement logging and monitoring

**You're ready to integrate with HUGE Foundations database! 🎉**



