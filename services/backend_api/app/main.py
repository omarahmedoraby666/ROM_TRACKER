from __future__ import annotations

from contextlib import asynccontextmanager
from typing import Any, Dict, Optional

from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware

from .auth import get_current_user, issue_access_token, require_role
from .database import (
    create_booking,
    get_ai_result,
    get_doctor_profile,
    get_session,
    get_user_by_email,
    hash_password,
    initialize_database,
    list_doctors,
    list_sessions_for_doctor,
    list_sessions_for_patient,
    list_slots_for_doctor,
    update_session_status,
    upsert_ai_result,
)
from .schemas import AIResultRequest, BookingRequest, DoctorsListResponse, LoginRequest, SessionStatusRequest, SlotsResponse


def error_response(
    message: str,
    code: Optional[str] = None,
    errors: Optional[Dict[str, Any]] = None,
):
    payload: Dict[str, Any] = {"message": message}
    if code:
        payload["code"] = code
    if errors:
        payload["errors"] = errors
    return payload


def serialize_user(user: Dict[str, Any], include_doctor_profile: bool = True) -> Dict[str, Any]:
    data = {
        "id": user["id"],
        "role": user["role"],
        "firstName": user["first_name"],
        "lastName": user["last_name"],
        "fullName": user["full_name"],
        "email": user["email"],
        "phoneCode": user["phone_code"],
        "phoneNumber": user["phone_number"],
        "country": user["country"],
        "gender": user["gender"],
        "avatarUrl": user["avatar_url"],
    }
    if include_doctor_profile and user["role"] == "doctor":
        doctor = get_doctor_profile(user["id"])
        if doctor:
            data.update(
                {
                    "specialization": doctor["specialization"],
                    "clinicAddress": doctor["clinic_address"],
                    "experienceYears": doctor["experience_years"],
                    "sessionPrice": doctor["session_price"],
                    "bio": doctor["bio"],
                    "rating": doctor["rating"],
                    "approvalStatus": doctor["approval_status"],
                }
            )
    return data


def serialize_doctor(doctor: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": doctor["id"],
        "fullName": doctor["full_name"],
        "email": doctor["email"],
        "avatarUrl": doctor["avatar_url"],
        "specialization": doctor["specialization"],
        "clinicAddress": doctor["clinic_address"],
        "experienceYears": doctor["experience_years"],
        "sessionPrice": doctor["session_price"],
        "bio": doctor["bio"],
        "rating": doctor["rating"],
    }


def serialize_slot(slot: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": slot["id"],
        "doctorId": slot["doctor_id"],
        "scheduledAt": slot["scheduled_at"],
        "displayTime": slot["display_time"],
        "isBooked": bool(slot["is_booked"]),
    }


def serialize_session(session: Dict[str, Any]) -> Dict[str, Any]:
    ai_result = get_ai_result(session["id"])
    data = {
        "id": session["id"],
        "patientId": session["patient_id"],
        "doctorId": session["doctor_id"],
        "doctorName": session["doctor_name"],
        "patientName": session["patient_name"],
        "specialty": session["specialty"],
        "status": session["status"],
        "reason": session["reason"],
        "scheduledAt": session["scheduled_at"],
        "displayTime": session["display_time"],
        "doctorNotes": session["doctor_notes"],
        "review": session["review"],
        "reviewRating": session["review_rating"],
        "paymentStatus": session["payment_status"],
        "createdAt": session["created_at"],
        "updatedAt": session["updated_at"],
        "aiResult": None,
    }
    if ai_result:
        data["aiResult"] = serialize_ai_result(ai_result)
    return data


def serialize_ai_result(result: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": result["id"],
        "sessionId": result["session_id"],
        "patientId": result["patient_id"],
        "doctorId": result["doctor_id"],
        "exercise": result["exercise"],
        "reps": result["reps"],
        "timestamp": result["captured_at"],
        "rawPayload": result["raw_payload"],
        "report": {
            "title": result["report_title"],
            "summary": result["report_summary"],
            "performanceLevel": result["performance_level"],
            "recommendations": result["recommendations"],
        },
    }


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database()
    yield


app = FastAPI(
    title="ROM Tracker Backend API",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {"message": "ROM Tracker backend is running"}


@app.post("/api/auth/login")
def login(payload: LoginRequest):
    user = get_user_by_email(payload.email)
    if not user or user["password_hash"] != hash_password(payload.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=error_response("Wrong email or password", "INVALID_CREDENTIALS"),
        )

    token = issue_access_token(user["id"])
    return {
        "accessToken": token,
        "user": serialize_user(user),
    }


@app.get("/api/users/me")
def get_me(current_user=Depends(get_current_user)):
    return serialize_user(current_user)


@app.get("/api/doctors", response_model=DoctorsListResponse)
def get_doctors(
    specialization: Optional[str] = Query(default=None),
    search: Optional[str] = Query(default=None),
):
    doctors = [serialize_doctor(doctor) for doctor in list_doctors(search=search, specialization=specialization)]
    return {"items": doctors}


@app.get("/api/doctors/{doctor_id}")
def get_doctor_details(doctor_id: str):
    doctor = get_doctor_profile(doctor_id)
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Doctor not found", "DOCTOR_NOT_FOUND"),
        )
    return serialize_doctor(doctor)


@app.get("/api/doctors/{doctor_id}/slots", response_model=SlotsResponse)
def get_doctor_slots(doctor_id: str):
    doctor = get_doctor_profile(doctor_id)
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Doctor not found", "DOCTOR_NOT_FOUND"),
        )
    return {"items": [serialize_slot(slot) for slot in list_slots_for_doctor(doctor_id)]}


@app.post("/api/bookings")
def create_booking_endpoint(
    payload: BookingRequest,
    patient=Depends(require_role("patient")),
):
    try:
        session = create_booking(
            patient_id=patient["id"],
            doctor_id=payload.doctorId,
            slot_id=payload.slotId,
            reason=payload.reason,
            patient_age=payload.patientAge,
            patient_gender=payload.patientGender,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "BOOKING_FAILED"),
        ) from exc

    return {"message": "Booking created successfully", "session": serialize_session(session)}


@app.get("/api/sessions/patient")
def get_patient_sessions(patient=Depends(require_role("patient"))):
    sessions = [serialize_session(item) for item in list_sessions_for_patient(patient["id"])]
    return {"items": sessions}


@app.get("/api/sessions/doctor")
def get_doctor_sessions(doctor=Depends(require_role("doctor"))):
    sessions = [serialize_session(item) for item in list_sessions_for_doctor(doctor["id"])]
    return {"items": sessions}


@app.get("/api/sessions/{session_id}")
def get_session_details(session_id: str, current_user=Depends(get_current_user)):
    session = get_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Session not found", "SESSION_NOT_FOUND"),
        )

    if current_user["id"] not in {session["patient_id"], session["doctor_id"]}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=error_response("You cannot access this session", "FORBIDDEN"),
        )

    return serialize_session(session)


@app.patch("/api/sessions/{session_id}/status")
def patch_session_status(
    session_id: str,
    payload: SessionStatusRequest,
    current_user=Depends(get_current_user),
):
    session = get_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Session not found", "SESSION_NOT_FOUND"),
        )

    if current_user["id"] not in {session["patient_id"], session["doctor_id"]}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=error_response("You cannot update this session", "FORBIDDEN"),
        )

    try:
        updated = update_session_status(
            session_id=session_id,
            status=payload.status,
            doctor_notes=payload.doctorNotes,
            review=payload.review,
            review_rating=payload.reviewRating,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "SESSION_UPDATE_FAILED"),
        ) from exc

    return {"message": "Session updated successfully", "session": serialize_session(updated)}


@app.post("/api/sessions/{session_id}/ai-result")
def submit_ai_result(
    session_id: str,
    payload: AIResultRequest,
    current_user=Depends(get_current_user),
):
    session = get_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Session not found", "SESSION_NOT_FOUND"),
        )

    if current_user["id"] not in {session["patient_id"], session["doctor_id"]}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=error_response("You cannot submit AI data for this session", "FORBIDDEN"),
        )

    try:
        result = upsert_ai_result(
            session_id=session_id,
            exercise=payload.exercise,
            reps=payload.reps,
            timestamp=payload.timestamp,
            raw_payload=payload.rawPayload,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "AI_RESULT_SAVE_FAILED"),
        ) from exc

    return {
        "message": "AI session result saved successfully",
        "aiResult": serialize_ai_result(result),
    }


@app.get("/api/sessions/{session_id}/ai-report")
def get_ai_report(session_id: str, current_user=Depends(get_current_user)):
    session = get_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Session not found", "SESSION_NOT_FOUND"),
        )

    if current_user["id"] not in {session["patient_id"], session["doctor_id"]}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=error_response("You cannot access this AI report", "FORBIDDEN"),
        )

    ai_result = get_ai_result(session_id)
    if not ai_result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("AI report not found for this session", "AI_REPORT_NOT_FOUND"),
        )

    return serialize_ai_result(ai_result)
