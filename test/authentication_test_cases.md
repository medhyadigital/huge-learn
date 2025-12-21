# Authentication Test Cases - Comprehensive Testing Guide

## 📋 Test Case Categories

### 1. Login Tests (Positive & Negative)

#### TC-LOGIN-001: Successful Login with Email ✅
**Type:** Positive  
**Preconditions:** Backend running, user exists in database  
**Steps:**
1. Open app
2. Enter valid email address (e.g., `test@example.com`)
3. Enter valid password (e.g., `test123`)
4. Tap "LOGIN" button

**Expected Result:**
- Loading spinner appears
- Button disabled during loading
- Success message: "Login successful!"
- Navigate to home screen
- User remains authenticated after app restart

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-002: Successful Login with Phone ✅
**Type:** Positive  
**Preconditions:** Backend running, user exists with phone number  
**Steps:**
1. Open app
2. Enter valid phone number (e.g., `1234567890`)
3. Enter valid password
4. Tap "LOGIN" button

**Expected Result:**
- Loading spinner appears
- Success message: "Login successful!"
- Navigate to home screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-003: Login with Invalid Email ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Enter invalid email (e.g., `invalid-email`)
2. Enter any password
3. Tap "LOGIN" button

**Expected Result:**
- Form validation error: "Please enter a valid email"
- Login button disabled or shows error
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-004: Login with Wrong Password ❌
**Type:** Negative  
**Preconditions:** Backend running, user exists  
**Steps:**
1. Enter valid email/phone
2. Enter wrong password
3. Tap "LOGIN" button

**Expected Result:**
- Loading spinner appears
- Error message: "Invalid credentials" or "Login failed"
- Red snackbar appears
- Stay on login screen
- No navigation

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-005: Login with Non-Existent User ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Enter email/phone that doesn't exist
2. Enter any password
3. Tap "LOGIN" button

**Expected Result:**
- Error message: "Invalid credentials"
- Stay on login screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-006: Login with Empty Email/Phone ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Leave email/phone field empty
2. Enter password
3. Tap "LOGIN" button

**Expected Result:**
- Form validation error: "Please enter your email or phone number"
- Login button disabled or shows error
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-007: Login with Empty Password ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Enter valid email/phone
2. Leave password empty
3. Tap "LOGIN" button

**Expected Result:**
- Form validation error: "Please enter your password"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-008: Login with Short Password ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Enter valid email/phone
2. Enter password less than 6 characters
3. Tap "LOGIN" button

**Expected Result:**
- Form validation error: "Password must be at least 6 characters"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-009: Login with Backend Offline ❌
**Type:** Negative  
**Preconditions:** Backend NOT running  
**Steps:**
1. Enter valid email/phone
2. Enter valid password
3. Tap "LOGIN" button

**Expected Result:**
- Error message: "Cannot connect to server. Please ensure the backend is running on http://localhost:3000"
- Clear, helpful error message
- Stay on login screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-010: Login with Network Timeout ❌
**Type:** Negative  
**Preconditions:** Backend running but slow/unresponsive  
**Steps:**
1. Enter valid credentials
2. Tap "LOGIN" button
3. Wait for timeout (30 seconds)

**Expected Result:**
- Loading spinner appears
- After timeout: Error message about connection timeout
- Stay on login screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-011: Password Visibility Toggle 👁️
**Type:** UI Test  
**Preconditions:** App open on login screen  
**Steps:**
1. Enter password
2. Tap eye icon

**Expected Result:**
- Password becomes visible
- Eye icon changes to "eye-off" icon
- Tapping again hides password

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-LOGIN-012: Loading State During Login ⏳
**Type:** UI Test  
**Preconditions:** Backend running  
**Steps:**
1. Enter valid credentials
2. Tap "LOGIN" button
3. Observe UI during API call

**Expected Result:**
- Button shows loading spinner
- Button disabled during loading
- Cannot tap button multiple times
- Loading state clears after response

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

### 2. Registration Tests (Positive & Negative)

#### TC-REG-001: Successful Registration with Email ✅
**Type:** Positive  
**Preconditions:** Backend running  
**Steps:**
1. Navigate to registration screen
2. Enter full name (e.g., `John Doe`)
3. Select "Email" option
4. Enter unique email (e.g., `newuser@example.com`)
5. Enter password (min 6 chars, e.g., `password123`)
6. Confirm password (same as password)
7. Tap "CREATE ACCOUNT" button

**Expected Result:**
- Loading spinner appears
- Success message: "Registration successful!"
- Navigate to home screen
- User is authenticated
- User data saved in database

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-002: Successful Registration with Phone ✅
**Type:** Positive  
**Preconditions:** Backend running  
**Steps:**
1. Navigate to registration screen
2. Enter full name
3. Select "Phone" option
4. Enter unique phone number (e.g., `9876543210`)
5. Enter password
6. Confirm password
7. Tap "CREATE ACCOUNT" button

**Expected Result:**
- Success message: "Registration successful!"
- Navigate to home screen
- User authenticated

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-003: Registration with Duplicate Email ❌
**Type:** Negative  
**Preconditions:** Backend running, user with email exists  
**Steps:**
1. Enter name
2. Select "Email"
3. Enter existing email
4. Enter password
5. Confirm password
6. Tap "CREATE ACCOUNT"

**Expected Result:**
- Error message: "User already exists with this email or phone"
- Stay on registration screen
- No navigation

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-004: Registration with Duplicate Phone ❌
**Type:** Negative  
**Preconditions:** Backend running, user with phone exists  
**Steps:**
1. Enter name
2. Select "Phone"
3. Enter existing phone number
4. Enter password
5. Confirm password
6. Tap "CREATE ACCOUNT"

**Expected Result:**
- Error message: "User already exists with this email or phone"
- Stay on registration screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-005: Registration with Empty Name ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Leave name field empty
2. Fill other fields
3. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Please enter your name"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-006: Registration with Short Name ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Enter name with 1 character
2. Fill other fields
3. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Name must be at least 2 characters"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-007: Registration with Invalid Email ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Select "Email" option
2. Enter invalid email (e.g., `invalid-email`)
3. Fill other fields
4. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Please enter a valid email"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-008: Registration with Empty Email (Email Selected) ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Select "Email" option
2. Leave email field empty
3. Fill other fields
4. Tap "CREATE ACCOUNT"

**Expected Result:**
- Error message: "Please enter your email"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-009: Registration with Empty Phone (Phone Selected) ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Select "Phone" option
2. Leave phone field empty
3. Fill other fields
4. Tap "CREATE ACCOUNT"

**Expected Result:**
- Error message: "Please enter either email or phone number"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-010: Registration with Short Password ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Fill name and email
2. Enter password less than 6 characters
3. Confirm password
4. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Password must be at least 6 characters"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-011: Registration with Password Mismatch ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Fill name and email
2. Enter password (e.g., `password123`)
3. Enter different confirm password (e.g., `password456`)
4. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Passwords do not match"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-012: Registration with Empty Password ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Fill name and email
2. Leave password empty
3. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Please enter your password"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-013: Registration with Empty Confirm Password ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Fill name, email, password
2. Leave confirm password empty
3. Tap "CREATE ACCOUNT"

**Expected Result:**
- Form validation error: "Please confirm your password"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-014: Registration with Backend Offline ❌
**Type:** Negative  
**Preconditions:** Backend NOT running  
**Steps:**
1. Fill all valid fields
2. Tap "CREATE ACCOUNT"

**Expected Result:**
- Error message: "Cannot connect to server. Please ensure the backend is running on http://localhost:3000"
- Stay on registration screen
- No navigation

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-015: Email/Phone Toggle Functionality 🔄
**Type:** UI Test  
**Preconditions:** On registration screen  
**Steps:**
1. Select "Email" option
2. Enter email
3. Switch to "Phone" option
4. Observe form

**Expected Result:**
- Email field hidden
- Phone field shown
- Previous email value cleared or hidden
- Can toggle back and forth

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-REG-016: Password Visibility Toggles 👁️
**Type:** UI Test  
**Preconditions:** On registration screen  
**Steps:**
1. Enter password
2. Tap eye icon on password field
3. Tap eye icon on confirm password field

**Expected Result:**
- Both fields can toggle visibility independently
- Icons change appropriately
- Passwords visible/hidden as expected

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

### 3. Forgot Password Tests

#### TC-FP-001: Forgot Password with Email ✅
**Type:** Positive  
**Preconditions:** Backend running, user exists  
**Steps:**
1. Navigate to forgot password screen
2. Enter valid email
3. Tap "SEND RESET LINK" button

**Expected Result:**
- Loading spinner appears
- Success message: "Reset instructions sent! Please check your email or phone."
- Success screen shown with checkmark icon
- Can navigate back to login

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-FP-002: Forgot Password with Phone ✅
**Type:** Positive  
**Preconditions:** Backend running, user exists  
**Steps:**
1. Navigate to forgot password screen
2. Enter valid phone number
3. Tap "SEND RESET LINK" button

**Expected Result:**
- Success message displayed
- Success screen shown

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-FP-003: Forgot Password with Empty Field ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Navigate to forgot password screen
2. Leave field empty
3. Tap "SEND RESET LINK"

**Expected Result:**
- Form validation error: "Please enter your email or phone number"
- No API call made

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-FP-004: Forgot Password with Non-Existent Email/Phone ❌
**Type:** Negative  
**Preconditions:** Backend running  
**Steps:**
1. Enter email/phone that doesn't exist
2. Tap "SEND RESET LINK"

**Expected Result:**
- Success message shown (to prevent user enumeration)
- No error about user not found

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-FP-005: Forgot Password with Backend Offline ❌
**Type:** Negative  
**Preconditions:** Backend NOT running  
**Steps:**
1. Enter valid email/phone
2. Tap "SEND RESET LINK"

**Expected Result:**
- Error message: "Cannot connect to server..."
- Stay on forgot password screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

### 4. Navigation Tests

#### TC-NAV-001: Login → Register Navigation 🔄
**Type:** Navigation  
**Steps:**
1. On login screen
2. Tap "Sign Up" link

**Expected Result:**
- Navigate to registration screen
- Form is empty
- Can navigate back

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-NAV-002: Login → Forgot Password Navigation 🔄
**Type:** Navigation  
**Steps:**
1. On login screen
2. Tap "Forgot Password?" link

**Expected Result:**
- Navigate to forgot password screen
- Back button available

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-NAV-003: Register → Login Navigation 🔄
**Type:** Navigation  
**Steps:**
1. On registration screen
2. Tap "Login" link

**Expected Result:**
- Navigate to login screen
- Form is empty

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-NAV-004: Forgot Password → Login Navigation 🔄
**Type:** Navigation  
**Steps:**
1. On forgot password screen
2. Tap "Back to Login" button

**Expected Result:**
- Navigate to login screen

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

### 5. Error Handling Tests

#### TC-ERR-001: Server Error (500) Handling ❌
**Type:** Error Handling  
**Preconditions:** Backend returns 500 error  
**Steps:**
1. Trigger any API call that returns 500

**Expected Result:**
- Error message displayed
- User-friendly error message
- App doesn't crash

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-ERR-002: Network Error Handling ❌
**Type:** Error Handling  
**Preconditions:** No internet connection  
**Steps:**
1. Disable internet
2. Try to login/register

**Expected Result:**
- Error message: "No internet connection"
- Clear error message
- App doesn't crash

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-ERR-003: Connection Refused Error ❌
**Type:** Error Handling  
**Preconditions:** Backend not running  
**Steps:**
1. Try to login/register

**Expected Result:**
- Error message: "Cannot connect to server. Please ensure the backend is running on http://localhost:3000"
- Helpful, actionable error message

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

### 6. UI/UX Tests

#### TC-UI-001: Large Tap Targets 🎯
**Type:** UI/UX  
**Steps:**
1. Check all buttons on authentication screens

**Expected Result:**
- All buttons are at least 72px tall
- Easy to tap
- Adequate spacing

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-UI-002: Icons with Labels 🏷️
**Type:** UI/UX  
**Steps:**
1. Check all icons on authentication screens

**Expected Result:**
- All icons have text labels
- Icons are clearly visible (32px minimum)
- Labels are readable (16-18px)

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-UI-003: Form Validation Feedback ✅
**Type:** UI/UX  
**Steps:**
1. Fill form fields incorrectly
2. Observe validation messages

**Expected Result:**
- Real-time validation
- Clear error messages
- Errors appear below fields
- Errors clear when fixed

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

#### TC-UI-004: Loading States ⏳
**Type:** UI/UX  
**Steps:**
1. Trigger any API call
2. Observe loading state

**Expected Result:**
- Loading spinner appears
- Button disabled during loading
- Clear visual feedback

**Actual Result:** [ ]  
**Status:** [ ] Pass / [ ] Fail  
**Notes:**

---

## 📊 Test Execution Summary

### Test Statistics
- **Total Test Cases:** 50+
- **Positive Tests:** 8
- **Negative Tests:** 30+
- **UI/UX Tests:** 8
- **Navigation Tests:** 4

### Test Execution Log
| Test ID | Status | Date | Tester | Notes |
|---------|--------|------|--------|-------|
| TC-LOGIN-001 | ⬜ | | | |
| TC-LOGIN-002 | ⬜ | | | |
| ... | ... | ... | ... | ... |

### Issues Found
1. [ ] Issue 1: Description
2. [ ] Issue 2: Description

---

## ✅ Test Completion Checklist

- [ ] All positive test cases executed
- [ ] All negative test cases executed
- [ ] All UI/UX test cases executed
- [ ] All navigation test cases executed
- [ ] All error handling test cases executed
- [ ] Issues documented
- [ ] Test results reviewed
- [ ] Sign-off completed

---

## 📝 Notes

- **Backend Required:** All API tests require backend running on `http://localhost:3000`
- **Test Data:** Use unique emails/phones for each test run
- **Cleanup:** Delete test users after testing if needed
- **Environment:** Test on both emulator and physical device

---

**Last Updated:** [Date]  
**Tested By:** [Name]  
**Reviewed By:** [Name]



