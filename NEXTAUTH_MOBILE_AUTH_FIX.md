# NextAuth.js Mobile Authentication Fix

## 🔴 Issue

**Error:** "This action with HTTP POST is not supported by NextAuth.js"

**Root Cause:** NextAuth.js blocks direct POST requests to `/api/auth/callback/credentials` from external clients (like mobile apps) for security reasons.

---

## ✅ Solution Implemented

The app now tries multiple authentication endpoints in order:

### 1. **Custom Mobile Endpoint** (First Attempt)
```
POST /api/auth/mobile/login
```
- If HUGE Foundations has a custom mobile authentication endpoint
- Returns user data directly

### 2. **Custom Login Endpoint** (Second Attempt)
```
POST /api/auth/login
```
- If HUGE Foundations has a custom login endpoint
- Returns user data or JWT tokens

### 3. **NextAuth Signin** (Third Attempt)
```
POST /api/auth/signin
```
- Standard NextAuth endpoint
- Requires CSRF token (attempts to fetch)
- Then fetches session via `GET /api/auth/session`

---

## 🔧 Code Changes

**File:** `lib/core/auth/auth_service.dart`

**Changes:**
- Implemented fallback authentication strategy
- Tries `/api/auth/mobile/login` first
- Falls back to `/api/auth/login`
- Finally tries `/api/auth/signin` with session fetch

---

## ⚠️ Important Notes

### Current Limitation
NextAuth.js is designed for web applications with cookies. For mobile apps, HUGE Foundations backend should expose a **custom mobile authentication endpoint** that:
1. Accepts email/password
2. Validates credentials
3. Returns user data directly (bypassing NextAuth restrictions)

### Recommended Backend Solution
HUGE Foundations should create a custom endpoint like:
```
POST /api/auth/mobile/login
```

This endpoint should:
- Accept `{ email, password }`
- Validate against HUGE database
- Return `{ user: {...}, expires: "..." }` format
- Bypass NextAuth restrictions for mobile clients

---

## 🧪 Testing

### Test the Fallback Strategy
1. **Test with Mobile Endpoint:**
   - If HUGE has `/api/auth/mobile/login`, it will work
   
2. **Test with Custom Login:**
   - If HUGE has `/api/auth/login`, it will work
   
3. **Test with NextAuth Signin:**
   - May require backend configuration to allow mobile clients
   - May require CSRF token handling

### Expected Behavior
- App tries endpoints in order
- First successful response is used
- If all fail, shows appropriate error message

---

## 📝 Next Steps

### Option 1: Backend Creates Mobile Endpoint (Recommended)
HUGE Foundations backend should create:
```
POST /api/auth/mobile/login
Request: { email, password }
Response: { user: {...}, expires: "..." }
```

### Option 2: Configure NextAuth for Mobile
HUGE Foundations backend needs to:
- Allow external POST requests to `/api/auth/callback/credentials`
- Or configure NextAuth to accept mobile clients
- This may require NextAuth configuration changes

### Option 3: Use Alternative Authentication
- Implement JWT-based authentication for mobile
- Separate from NextAuth web authentication
- Mobile gets JWT tokens, web uses NextAuth sessions

---

## 🔍 Debugging

If login still fails, check:

1. **Backend Logs:**
   - Check which endpoint is being called
   - Check error messages from backend

2. **Network Requests:**
   - Use Flutter DevTools to inspect API calls
   - Check request/response format

3. **Backend Configuration:**
   - Verify NextAuth configuration
   - Check if mobile endpoints exist
   - Verify CORS settings

---

## 📱 Current APK Status

**APK Location:** `build\app\outputs\flutter-apk\app-release.apk`  
**APK Size:** 48.9 MB  
**Status:** ✅ Built Successfully

**Authentication:** Implements fallback strategy for multiple endpoints

---

## 💡 Recommendation

**Contact HUGE Foundations backend team** to:
1. Confirm if `/api/auth/mobile/login` endpoint exists
2. Or create a custom mobile authentication endpoint
3. Or configure NextAuth to allow mobile client authentication

The current implementation will work once the backend exposes a mobile-friendly authentication endpoint.

---

**Last Updated:** [Current Date]  
**Status:** ⚠️ Waiting for backend mobile authentication endpoint


