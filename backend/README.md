# HUGE Learning Platform - Backend API

## ✅ Status: RUNNING

Backend API server for the HUGE Learning Platform with mock data.

---

## 🚀 Quick Start

```bash
cd backend

# Install dependencies
npm install

# Start development server
npm run dev

# Server will run on http://localhost:3000
```

---

## 📡 Available Endpoints

### Authentication
- `POST /api/auth/login` - Login with email/password
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user

### Learning Platform
- `GET /api/learning/schools` - Get all learning schools
- `GET /api/learning/schools/:schoolId/courses` - Get courses for a school
- `GET /api/learning/courses/:courseId` - Get course details
- `POST /api/learning/courses/:courseId/enroll` - Enroll in course
- `GET /api/learning/profile/me` - Get or create learning profile
- `PUT /api/learning/profile/me` - Update learning profile
- `GET /api/learning/gamification/metrics` - Get user metrics (XP, Karma, etc.)
- `GET /api/learning/gamification/badges` - Get user badges

---

## 🧪 Testing Endpoints

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@hugefoundations.com","password":"any"}'
```

### Get Schools
```bash
curl http://localhost:3000/api/learning/schools
```

### Get Learning Profile
```bash
curl http://localhost:3000/api/learning/profile/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## ⚠️ Important: Database Status

**Currently using MOCK DATA** because:
- The provided database (`cltlsyxm_huge`) is the PRODUCTION HUGE Foundations database
- Cannot create new database without additional permissions
- Waiting for database creation permissions or separate database

**What's ready:**
- ✅ Complete Prisma schema (`prisma/schema.prisma`)
- ✅ 33 tables defined
- ✅ All relationships mapped
- ✅ Ready to migrate when database is available

**To use real database:**
1. Get permission to create `cltlsyxm_HUGE_Learning` database
2. Or get credentials for separate MySQL server
3. Run: `npx prisma db push`
4. Replace mock data with Prisma queries

---

## 🗄️ Mock Data

Currently using in-memory mock data for:
- 4 Learning Schools
- 2 Sample Courses
- Auto-created learning profiles
- Mock gamification metrics

**This allows immediate testing of Flutter app while database is being set up.**

---

## 🔐 Environment Variables

Create `.env` file (see `.env.example`):
```env
DATABASE_URL="mysql://user:pass@host:port/database"
JWT_SECRET="your-secret"
PORT="3000"
NODE_ENV="development"
```

---

## 📦 Dependencies

- `express` - Web framework
- `@prisma/client` - Database ORM
- `jsonwebtoken` - JWT tokens
- `bcrypt` - Password hashing
- `cors` - CORS support
- `dotenv` - Environment variables

---

## 🔜 Next Steps

1. **Get database permissions** - Contact DB admin
2. **Run migrations** - `npm run prisma:migrate`
3. **Replace mock data** - With Prisma client queries
4. **Add validation** - express-validator
5. **Add more endpoints** - From API spec

---

## 📞 Support

See `DATABASE_ACCESS_ISSUE.md` for database access notes.



