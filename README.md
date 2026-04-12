# ROM Tracker Monorepo

This repository contains the full ROM Tracker project in a single monorepo structure.

## Structure

```text
rom_tracker_app/
├─ apps/
│  └─ flutter_app/
├─ services/
│  └─ backend_api/
├─ docs/
├─ postman/
├─ ai/
└─ .github/
```

## Main Workspaces

### Flutter App

Path:

`apps/flutter_app`

This contains:

- UI
- navigation flows
- local demo logic
- backend integration scaffolding
- future Unity/AI host screen

### Backend API

Path:

`services/backend_api`

This is reserved for the backend implementation.

### Documentation

Path:

`docs`

Important files:

- `backend_api_contract_en.md`
- `backend_handoff_message_en.md`
- `backend_handoff_message_ar.md`

### Postman

Path:

`postman`

Use this folder for:

- API collections
- environment files
- request examples

### AI

Path:

`ai`

Use this folder for:

- Unity integration notes
- AI handoff files
- future Unity export or guides

## Current Development Priority

Priority P0 integration flow:

1. Login
2. Load current user profile
3. Load doctors list
4. Load doctor details
5. Load doctor slots
6. Create booking
7. Load patient sessions
8. Load doctor sessions
9. Update session status
10. Submit AI result after Unity session

## How To Run Flutter App

```powershell
cd apps/flutter_app
flutter pub get
flutter run
```

## Collaboration Notes

- Keep Flutter changes inside `apps/flutter_app`
- Keep backend changes inside `services/backend_api`
- Keep the API contract in sync with real backend delivery
- Use GitHub issues / pull requests instead of chat-only coordination
