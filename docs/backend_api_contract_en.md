# ROM Tracker Backend API Contract

## Purpose

This document defines the backend contract required by the Flutter application.
It is written for both:

- the backend developer
- any Codex agent working on the backend side

The current Flutter app already has a complete local demo flow. The goal of this contract is to replace local mock logic with real backend APIs gradually, without rebuilding the UI.

## Delivery Strategy

The backend work should be delivered by priority, not all at once.

### Priority P0: Critical MVP Flow

This is the minimum real backend scope required to demonstrate the main project flow:

1. Login
2. Load current user profile
3. Load doctors list
4. Load doctor details
5. Load doctor available slots
6. Create booking
7. Load patient sessions
8. Load doctor sessions
9. Update session status
10. Submit AI session result

### Priority P1: Important Expansion

1. Register patient
2. Register doctor
3. Doctor approval status
4. Notifications feed
5. Reviews
6. Wishlist

### Priority P2: Secondary Features

1. Forgot password
2. OTP verification
3. Reset password
4. Wallet history
5. Contact us submissions
6. Search endpoints
7. Chat realtime backend
8. Push notifications

## Required Global Rules

### Base URL

Backend should provide one testable base URL, for example:

`http://localhost:3000/api`

or

`http://192.168.x.x:3000/api`

### Authentication

Use Bearer token authentication.

Expected flow:

1. Flutter sends login/register request
2. Backend returns access token
3. Flutter stores the token locally
4. Flutter sends `Authorization: Bearer <token>` in protected requests

### Error Response Format

Every endpoint should return a predictable error object:

```json
{
  "message": "Human readable error message",
  "code": "OPTIONAL_MACHINE_CODE",
  "errors": {
    "fieldName": ["Validation message"]
  }
}
```

### Time Format

Use ISO-8601 timestamps:

```json
"2026-04-12T10:30:00Z"
```

### File Uploads

Doctor registration documents and profile images should support multipart upload.

## Shared Core Models

### User

```json
{
  "id": "user_001",
  "role": "patient",
  "firstName": "Gamal",
  "lastName": "Ali",
  "fullName": "Gamal Ali",
  "email": "patient@app.com",
  "phoneCode": "+20",
  "phoneNumber": "1234567891",
  "country": "Egypt",
  "gender": "Male",
  "avatarUrl": "https://..."
}
```

### Doctor

```json
{
  "id": "doctor_001",
  "fullName": "Mohamed Alaa",
  "email": "doctor@app.com",
  "avatarUrl": "https://...",
  "specialization": "Physical Therapist",
  "clinicAddress": "Active Care Physiotherapy Center Cairo",
  "experienceYears": 7,
  "sessionPrice": 350,
  "bio": "Short doctor bio",
  "rating": 4.8
}
```

### Session

```json
{
  "id": "session_001",
  "patientId": "user_001",
  "doctorId": "doctor_001",
  "doctorName": "Mohamed Alaa",
  "patientName": "Gamal Ali",
  "specialty": "Physical Therapist",
  "status": "upcoming",
  "reason": "Knee recovery follow-up",
  "scheduledAt": "2026-04-12T10:30:00Z",
  "displayTime": "Sat 12 - 10:30 am",
  "doctorNotes": "Short notes",
  "review": null,
  "paymentStatus": "paid"
}
```

### AI Session Result

```json
{
  "patientId": "user_001",
  "sessionId": "session_001",
  "exercise": "Squat",
  "reps": 12,
  "timestamp": "2026-04-12T10:30:00Z"
}
```

## P0 Endpoints

### 1. Login

**POST** `/auth/login`

Request:

```json
{
  "email": "patient@app.com",
  "password": "123456"
}
```

Response:

```json
{
  "accessToken": "jwt_or_token_here",
  "user": {
    "id": "user_001",
    "role": "patient",
    "firstName": "Gamal",
    "lastName": "Ali",
    "fullName": "Gamal Ali",
    "email": "patient@app.com",
    "phoneCode": "+20",
    "phoneNumber": "1234567891",
    "country": "Egypt",
    "gender": "Male",
    "avatarUrl": "https://..."
  }
}
```

### 2. Get Current User

**GET** `/users/me`

Response:

```json
{
  "id": "user_001",
  "role": "patient",
  "firstName": "Gamal",
  "lastName": "Ali",
  "fullName": "Gamal Ali",
  "email": "patient@app.com",
  "phoneCode": "+20",
  "phoneNumber": "1234567891",
  "country": "Egypt",
  "gender": "Male",
  "avatarUrl": "https://..."
}
```

If role is doctor, the response should also include:

```json
{
  "specialization": "Physical Therapist",
  "clinicAddress": "Active Care Physiotherapy Center Cairo",
  "approvalStatus": "approved"
}
```

### 3. Get Doctors List

**GET** `/doctors`

Optional query params:

- `specialization`
- `search`
- `page`
- `limit`

Response:

```json
{
  "items": [
    {
      "id": "doctor_001",
      "fullName": "Mohamed Alaa",
      "avatarUrl": "https://...",
      "specialization": "Physical Therapist",
      "experienceYears": 7,
      "sessionPrice": 350,
      "rating": 4.8
    }
  ],
  "total": 1
}
```

### 4. Get Doctor Details

**GET** `/doctors/{doctorId}`

Response:

```json
{
  "id": "doctor_001",
  "fullName": "Mohamed Alaa",
  "email": "doctor@app.com",
  "avatarUrl": "https://...",
  "specialization": "Physical Therapist",
  "clinicAddress": "Active Care Physiotherapy Center Cairo",
  "experienceYears": 7,
  "sessionPrice": 350,
  "bio": "Short doctor bio",
  "rating": 4.8
}
```

### 5. Get Doctor Available Slots

**GET** `/doctors/{doctorId}/slots`

Response:

```json
{
  "doctorId": "doctor_001",
  "slots": [
    {
      "id": "slot_001",
      "date": "2026-04-12",
      "label": "Sat 12",
      "timeLabel": "10:30 am",
      "startsAt": "2026-04-12T10:30:00Z",
      "isAvailable": true
    }
  ]
}
```

### 6. Create Booking

**POST** `/bookings`

Request:

```json
{
  "doctorId": "doctor_001",
  "slotId": "slot_001",
  "patientDetails": {
    "fullName": "Gamal Ali",
    "age": 24,
    "gender": "Male",
    "reason": "Knee recovery follow-up"
  },
  "paymentMethod": "demo_or_real"
}
```

Response:

```json
{
  "bookingId": "booking_001",
  "session": {
    "id": "session_001",
    "patientId": "user_001",
    "doctorId": "doctor_001",
    "doctorName": "Mohamed Alaa",
    "patientName": "Gamal Ali",
    "specialty": "Physical Therapist",
    "status": "upcoming",
    "reason": "Knee recovery follow-up",
    "scheduledAt": "2026-04-12T10:30:00Z",
    "displayTime": "Sat 12 - 10:30 am",
    "doctorNotes": "",
    "review": null,
    "paymentStatus": "paid"
  }
}
```

### 7. Get Patient Sessions

**GET** `/sessions/patient`

Optional query:

- `status=upcoming|completed|canceled`

Response:

```json
{
  "items": [
    {
      "id": "session_001",
      "doctorId": "doctor_001",
      "doctorName": "Mohamed Alaa",
      "specialty": "Physical Therapist",
      "doctorAvatarUrl": "https://...",
      "status": "upcoming",
      "reason": "Knee recovery follow-up",
      "scheduledAt": "2026-04-12T10:30:00Z",
      "displayTime": "Sat 12 - 10:30 am",
      "doctorNotes": "",
      "review": null
    }
  ]
}
```

### 8. Get Doctor Sessions

**GET** `/sessions/doctor`

Optional query:

- `status=upcoming|completed|canceled`

Response:

```json
{
  "items": [
    {
      "id": "session_001",
      "patientId": "user_001",
      "patientName": "Gamal Ali",
      "patientAvatarUrl": "https://...",
      "condition": "Knee recovery follow-up",
      "status": "upcoming",
      "scheduledAt": "2026-04-12T10:30:00Z",
      "displayTime": "Sat 12 - 10:30 am",
      "doctorNotes": ""
    }
  ]
}
```

### 9. Update Session Status

**PATCH** `/sessions/{sessionId}/status`

Request:

```json
{
  "status": "completed"
}
```

Allowed values:

- `upcoming`
- `completed`
- `canceled`

Response:

```json
{
  "id": "session_001",
  "status": "completed"
}
```

### 10. Submit AI Session Result

**POST** `/sessions/{sessionId}/ai-result`

Request:

```json
{
  "patientId": "user_001",
  "exercise": "Squat",
  "reps": 12,
  "timestamp": "2026-04-12T10:30:00Z"
}
```

Response:

```json
{
  "sessionId": "session_001",
  "exercise": "Squat",
  "reps": 12,
  "timestamp": "2026-04-12T10:30:00Z",
  "saved": true
}
```

### 11. Optional Session Start Handshake

This endpoint is recommended if the Flutter app should formally mark the AI-assisted exercise session as started before opening Unity.

**POST** `/sessions/{sessionId}/start`

Request:

```json
{
  "startedAt": "2026-04-12T10:25:00Z"
}
```

Response:

```json
{
  "sessionId": "session_001",
  "status": "in_progress",
  "startedAt": "2026-04-12T10:25:00Z"
}
```

## P1 Endpoints

### Register Patient

**POST** `/auth/register/patient`

### Register Doctor

**POST** `/auth/register/doctor`

This should support multipart form data for:

- profile image
- professional document
- membership card

### Doctor Approval Status

**GET** `/doctor-application/status`

Possible values:

- `approved`
- `pending`
- `rejected`

### Notifications Feed

**GET** `/notifications`

### Mark Notification Read

**PATCH** `/notifications/{notificationId}/read`

### Reviews

**POST** `/sessions/{sessionId}/review`

### Wishlist

**GET** `/wishlist`

**POST** `/wishlist/{doctorId}`

**DELETE** `/wishlist/{doctorId}`

## P2 Endpoints

### Forgot Password

**POST** `/auth/forgot-password`

### Verify OTP

**POST** `/auth/verify-otp`

### Reset Password

**POST** `/auth/reset-password`

### Wallet

**GET** `/wallet/doctor`

### Contact Us

**POST** `/support/contact`

### Search

**GET** `/search`

### Chat

Possible options:

- REST only
- REST + realtime socket

Minimum endpoints:

- `GET /chat/threads`
- `GET /chat/threads/{threadId}/messages`
- `POST /chat/threads/{threadId}/messages`

## Flutter Integration Notes

### Current Flutter Local Replacements

These local classes will gradually be replaced by backend APIs:

- `MockAuthService`
- `BookingStore`
- `DoctorSessionStore`
- `LocalDemoSyncStore`
- `ChatStore`
- `NotificationStore`
- `DoctorWalletStore`
- `WishlistStore`

### Flutter Team Immediate Need

The backend team should first deliver:

1. Base URL
2. Auth endpoint
3. Me endpoint
4. Doctors list/details/slots
5. Booking creation
6. Sessions list for patient and doctor
7. Session status update
8. AI result submission endpoint

## AI Camera Note

The AI module is not fully available yet on the Flutter side.

Backend should still prepare the AI result endpoint now.

### What the Backend Needs for AI / Camera

The camera view itself is expected to be hosted by Unity inside Flutter.
That means:

- Flutter does not run the computer vision model directly
- Backend does not need to stream camera frames
- Backend does not need to control the camera UI

What the backend **does** need to support is:

1. A valid booked session that belongs to the logged-in patient
2. A stable `sessionId` that Flutter can use before opening the Unity view
3. An endpoint to save the AI summary after the exercise finishes
4. Optionally, an endpoint to mark the session as started

### What the Backend Does NOT Need for AI

The backend does not need to:

- receive live video frames
- run pose estimation
- host the Unity scene
- render camera overlays

Those parts belong to:

- Unity / AI module
- Flutter host screen

### Recommended AI Result Validation

When Flutter submits the AI result, backend should validate:

- the `sessionId` exists
- the session belongs to the current patient
- the session belongs to the assigned doctor
- the payload contains:
  - `exercise`
  - `reps`
  - `timestamp`

### Optional Future AI Endpoints

These are not required for the first delivery, but may be useful later:

- `GET /sessions/{sessionId}/ai-result`
- `GET /exercises`
- `GET /sessions/{sessionId}/exercise-plan`

Flutter will later receive JSON from Unity in this shape:

```json
{
  "exercise": "Squat",
  "reps": 12
}
```

Flutter will append:

- `patientId`
- `sessionId`
- `timestamp`

Then it will send the final payload to the backend.

This means the backend can prepare this endpoint immediately even before the Unity package is delivered.

## Final Backend Handoff Request

Backend developer should provide:

1. Base URL
2. Swagger or Postman collection
3. Authentication method details
4. Request and response examples
5. Final enum values for statuses
6. Final field names for all P0 endpoints
7. Any file upload requirements

Once these are provided, Flutter can start replacing the local demo flow with real API calls immediately.
