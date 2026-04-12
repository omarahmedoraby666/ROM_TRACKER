Hi,

I have prepared the Flutter side for backend integration and documented the full API contract here:

`D:\rom_tracker_app\docs\backend_api_contract_en.md`

For now, we want to start with the critical MVP flow only.

## Priority P0 endpoints we need first

1. `POST /auth/login`
2. `GET /users/me`
3. `GET /doctors`
4. `GET /doctors/{id}`
5. `GET /doctors/{id}/slots`
6. `POST /bookings`
7. `GET /sessions/patient`
8. `GET /sessions/doctor`
9. `PATCH /sessions/{id}/status`
10. `POST /sessions/{id}/ai-result`
11. Optional: `POST /sessions/{id}/start`

## What we need from you

1. Base URL
2. Swagger or Postman collection
3. Authentication method details
4. Request and response examples
5. Final enum/status values
6. Field names for the P0 endpoints

## AI / Camera note

The camera + computer vision part is expected to run inside Unity, hosted in Flutter.
So the backend does not need to process video frames.
What we need from backend for AI is:

- a valid session id before opening the AI flow
- an endpoint to save the AI summary result after Unity finishes
- optionally an endpoint to mark the session as started

Unity is expected to return a JSON payload like:

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

Then Flutter will send the final payload to the backend.

We already prepared Flutter integration scaffolding and can start wiring the real APIs as soon as you send the first P0 batch.
