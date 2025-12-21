# APK Testing Guide - Authentication Functionality

## ✅ APK Build Complete

**APK Location:** `build\app\outputs\flutter-apk\app-release.apk`  
**APK Size:** 47.9 MB  
**Build Type:** Release

---

## 📱 Installation Instructions

### Option 1: Direct Install (Android Device)
1. Transfer the APK file to your Android device
2. Enable "Install from Unknown Sources" in device settings
3. Open the APK file and tap "Install"
4. Launch the app

### Option 2: ADB Install (Development)
```bash
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## 🔧 Backend Setup (Required)

**IMPORTANT:** The app requires the backend server to be running!

### Start Backend Server:
```bash
cd backend
npm install  # If not already done
npm run dev
```

The backend should be running on: `http://localhost:3000`

### For Testing on Physical Device:
If testing on a physical device (not emulator), you need to:

1. **Find your computer's IP address:**
   - Windows: `ipconfig` (look for IPv4 address)
   - Mac/Linux: `ifconfig` or `ip addr`

2. **Update API URLs in the app:**
   - Edit `lib/core/constants/app_constants.dart`
   - Change `localhost:3000` to `YOUR_IP_ADDRESS:3000`
   - Example: `http://192.168.1.100:3000`
   - Rebuild APK: `flutter build apk --release`

3. **Ensure firewall allows connections:**
   - Allow port 3000 in Windows Firewall

---

## 🧪 Testing Checklist

### 1. **Login Testing**

#### Test Case 1.1: Login with Email
- [ ] Open the app
- [ ] Enter a valid email address
- [ ] Enter password
- [ ] Tap "LOGIN"
- [ ] **Expected:** Navigate to home screen, show success message

#### Test Case 1.2: Login with Phone
- [ ] Open the app
- [ ] Enter a phone number (e.g., `1234567890`)
- [ ] Enter password
- [ ] Tap "LOGIN"
- [ ] **Expected:** Navigate to home screen, show success message

#### Test Case 1.3: Invalid Credentials
- [ ] Enter wrong email/phone
- [ ] Enter wrong password
- [ ] Tap "LOGIN"
- [ ] **Expected:** Show error message "Invalid credentials"

#### Test Case 1.4: Empty Fields
- [ ] Leave email/phone empty
- [ ] Leave password empty
- [ ] Tap "LOGIN"
- [ ] **Expected:** Show validation errors

#### Test Case 1.5: Loading State
- [ ] Enter credentials
- [ ] Tap "LOGIN"
- [ ] **Expected:** Show loading spinner, button disabled

---

### 2. **Registration Testing**

#### Test Case 2.1: Register with Email
- [ ] Tap "Sign Up" on login screen
- [ ] Enter full name
- [ ] Select "Email" option
- [ ] Enter email address
- [ ] Enter password (min 6 characters)
- [ ] Confirm password (must match)
- [ ] Tap "CREATE ACCOUNT"
- [ ] **Expected:** Navigate to home screen, account created

#### Test Case 2.2: Register with Phone
- [ ] Tap "Sign Up" on login screen
- [ ] Enter full name
- [ ] Select "Phone" option
- [ ] Enter phone number
- [ ] Enter password
- [ ] Confirm password
- [ ] Tap "CREATE ACCOUNT"
- [ ] **Expected:** Navigate to home screen, account created

#### Test Case 2.3: Password Mismatch
- [ ] Enter password
- [ ] Enter different confirm password
- [ ] Tap "CREATE ACCOUNT"
- [ ] **Expected:** Show error "Passwords do not match"

#### Test Case 2.4: Weak Password
- [ ] Enter password less than 6 characters
- [ ] Tap "CREATE ACCOUNT"
- [ ] **Expected:** Show error "Password must be at least 6 characters"

#### Test Case 2.5: Duplicate User
- [ ] Try to register with existing email/phone
- [ ] **Expected:** Show error "User already exists"

---

### 3. **Forgot Password Testing**

#### Test Case 3.1: Request Reset with Email
- [ ] Tap "Forgot Password?" on login screen
- [ ] Enter email address
- [ ] Tap "SEND RESET LINK"
- [ ] **Expected:** Show success message

#### Test Case 3.2: Request Reset with Phone
- [ ] Tap "Forgot Password?" on login screen
- [ ] Enter phone number
- [ ] Tap "SEND RESET LINK"
- [ ] **Expected:** Show success message

#### Test Case 3.3: Empty Field
- [ ] Leave email/phone empty
- [ ] Tap "SEND RESET LINK"
- [ ] **Expected:** Show validation error

---

### 4. **Navigation Testing**

#### Test Case 4.1: Login → Register
- [ ] On login screen, tap "Sign Up"
- [ ] **Expected:** Navigate to registration screen

#### Test Case 4.2: Login → Forgot Password
- [ ] On login screen, tap "Forgot Password?"
- [ ] **Expected:** Navigate to forgot password screen

#### Test Case 4.3: Register → Login
- [ ] On registration screen, tap "Login"
- [ ] **Expected:** Navigate back to login screen

#### Test Case 4.4: Forgot Password → Login
- [ ] On forgot password screen, tap "Back to Login"
- [ ] **Expected:** Navigate back to login screen

---

### 5. **UI/UX Testing**

#### Test Case 5.1: Large Tap Targets
- [ ] Verify buttons are at least 72px tall
- [ ] Verify buttons are easy to tap

#### Test Case 5.2: Icons + Labels
- [ ] Verify all icons have text labels
- [ ] Verify icons are clearly visible

#### Test Case 5.3: Password Visibility Toggle
- [ ] Tap eye icon on password field
- [ ] **Expected:** Password becomes visible/hidden

#### Test Case 5.4: Form Validation
- [ ] Verify real-time validation messages
- [ ] Verify error messages are clear

#### Test Case 5.5: Loading States
- [ ] Verify loading spinner appears during API calls
- [ ] Verify buttons are disabled during loading

---

## 🐛 Common Issues & Solutions

### Issue 1: "Network Error" or "Connection Failed"
**Solution:**
- Ensure backend is running (`npm run dev` in backend folder)
- Check if device/emulator can reach backend URL
- For physical device, update API URL to use computer's IP address

### Issue 2: "Invalid Credentials" Even with Correct Password
**Solution:**
- Check backend logs for errors
- Verify database connection in backend `.env` file
- Ensure user exists in database with correct password hash

### Issue 3: App Crashes on Launch
**Solution:**
- Check device Android version (min SDK 21)
- Check device storage space
- Reinstall APK

### Issue 4: Registration Fails
**Solution:**
- Check backend logs
- Verify database connection
- Ensure email/phone is unique

---

## 📊 Test Data

### Test Users (Create these in database if needed):

**User 1 (Email):**
- Email: `test@example.com`
- Password: `test123`
- Name: `Test User`

**User 2 (Phone):**
- Phone: `1234567890`
- Password: `test123`
- Name: `Phone User`

---

## 🔍 Backend Logs

Monitor backend logs while testing:
```bash
cd backend
npm run dev
```

Look for:
- Login attempts
- Registration attempts
- Database queries
- Error messages

---

## ✅ Success Criteria

The authentication is working correctly if:
1. ✅ Users can login with email or phone
2. ✅ Users can register with email or phone
3. ✅ Password validation works
4. ✅ Error messages are clear and helpful
5. ✅ Loading states work correctly
6. ✅ Navigation flows smoothly
7. ✅ Tokens are stored securely
8. ✅ Users stay logged in after app restart

---

## 📝 Notes

- **Backend Required:** The app will not work without the backend server running
- **Database:** Uses HUGE Foundations database (`cltlsyxm_huge`)
- **Password Hashing:** Uses bcrypt (10 rounds)
- **Tokens:** JWT tokens stored securely in SharedPreferences
- **Network:** Requires internet connection or local network access to backend

---

## 🚀 Next Steps After Testing

1. Report any bugs or issues
2. Test on different Android versions
3. Test on different screen sizes
4. Test with slow network connection
5. Test offline behavior (should show network error)

---

**Happy Testing! 🎉**


