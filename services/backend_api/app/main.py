from __future__ import annotations

from contextlib import asynccontextmanager
from typing import Any, Dict, Optional

from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware

from .auth import get_current_user, issue_access_token, require_admin_key, require_role
from .database import (
    add_doctor_to_wishlist,
    create_contact_submission,
    create_doctor_account,
    create_booking,
    create_patient_account,
    get_doctor_dashboard_summary,
    get_ai_result,
    get_user_by_id,
    get_doctor_profile,
    get_session,
    get_user_by_email,
    hash_password,
    initialize_database,
    list_doctor_applications,
    list_doctors,
    list_notifications_for_user,
    list_reviews_for_doctor,
    list_reviews_for_patient,
    list_sessions_for_doctor,
    list_sessions_for_patient,
    list_slots_for_doctor,
    list_ai_results_for_patient_exercise,
    list_wallet_transactions_for_doctor,
    list_wishlist_for_patient,
    mark_notification_read,
    remove_doctor_from_wishlist,
    start_session,
    submit_session_review,
    update_doctor_approval_status,
    update_session_status,
    update_user_profile,
    upsert_ai_result,
)
from .schemas import (
    AIResultRequest,
    BookingRequest,
    ContactSubmissionRequest,
    DoctorApplicationDecisionRequest,
    DoctorsListResponse,
    LoginRequest,
    RegisterDoctorRequest,
    RegisterPatientRequest,
    ReviewRequest,
    SessionStartRequest,
    SessionStatusRequest,
    SlotsResponse,
    UpdateProfileRequest,
)


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
        "startedAt": session.get("started_at"),
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
            "metrics": result.get("report_metrics") or {},
        },
    }


def serialize_notification(notification: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": notification["id"],
        "type": notification["type"],
        "title": notification["title"],
        "body": notification["body"],
        "isRead": bool(notification["is_read"]),
        "relatedSessionId": notification["related_session_id"],
        "relatedDoctorId": notification["related_doctor_id"],
        "relatedPatientId": notification["related_patient_id"],
        "createdAt": notification["created_at"],
    }


def serialize_wishlist_item(item: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "wishlistId": item["wishlist_id"],
        "createdAt": item["wishlist_created_at"],
        "doctor": serialize_doctor(item),
    }


def serialize_review(review: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": review["id"],
        "sessionId": review["session_id"],
        "patientId": review["patient_id"],
        "doctorId": review["doctor_id"],
        "patientName": review["patient_name"],
        "doctorName": review["doctor_name"],
        "rating": review["rating"],
        "comment": review["comment"],
        "createdAt": review["created_at"],
    }


def serialize_wallet_transaction(transaction: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": transaction["id"],
        "sessionId": transaction["session_id"],
        "doctorId": transaction["doctor_id"],
        "doctorName": transaction["doctor_name"],
        "patientId": transaction["patient_id"],
        "patientName": transaction["patient_name"],
        "amount": transaction["amount"],
        "status": transaction["status"],
        "description": transaction["description"],
        "releasedAt": transaction["released_at"],
        "createdAt": transaction["created_at"],
        "updatedAt": transaction["updated_at"],
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


@app.post("/api/auth/register/patient")
def register_patient(payload: RegisterPatientRequest):
    try:
        user = create_patient_account(
            first_name=payload.firstName,
            last_name=payload.lastName,
            email=payload.email,
            password=payload.password,
            phone_code=payload.phoneCode,
            phone_number=payload.phoneNumber,
            country=payload.country,
            gender=payload.gender,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "PATIENT_REGISTER_FAILED"),
        ) from exc

    token = issue_access_token(user["id"])
    return {
        "message": "Patient account created successfully",
        "accessToken": token,
        "user": serialize_user(user),
    }


@app.post("/api/auth/register/doctor")
def register_doctor(payload: RegisterDoctorRequest):
    try:
        doctor = create_doctor_account(
            first_name=payload.firstName,
            last_name=payload.lastName,
            email=payload.email,
            password=payload.password,
            phone_code=payload.phoneCode,
            phone_number=payload.phoneNumber,
            country=payload.country,
            gender=payload.gender,
            specialization=payload.specialization,
            clinic_address=payload.clinicAddress,
            experience_years=payload.experienceYears,
            session_price=payload.sessionPrice,
            bio=payload.bio,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "DOCTOR_REGISTER_FAILED"),
        ) from exc

    token = issue_access_token(doctor["id"])
    return {
        "message": "Doctor account created successfully and is pending approval",
        "accessToken": token,
        "user": serialize_user(doctor),
    }


@app.get("/api/users/me")
def get_me(current_user=Depends(get_current_user)):
    return serialize_user(current_user)


@app.patch("/api/users/me")
def patch_me(
    payload: UpdateProfileRequest,
    current_user=Depends(get_current_user),
):
    changes = payload.model_dump(exclude_none=True)
    if not changes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response("No profile fields were provided", "PROFILE_UPDATE_EMPTY"),
        )

    if current_user["role"] != "doctor":
        doctor_only_fields = {"specialization", "clinicAddress", "experienceYears", "sessionPrice", "bio"}
        if doctor_only_fields.intersection(changes):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=error_response("Doctor profile fields are not allowed for patients", "FORBIDDEN"),
            )

    try:
        updated = update_user_profile(
            user_id=current_user["id"],
            first_name=payload.firstName,
            last_name=payload.lastName,
            phone_code=payload.phoneCode,
            phone_number=payload.phoneNumber,
            country=payload.country,
            gender=payload.gender,
            avatar_url=payload.avatarUrl,
            specialization=payload.specialization,
            clinic_address=payload.clinicAddress,
            experience_years=payload.experienceYears,
            session_price=payload.sessionPrice,
            bio=payload.bio,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "PROFILE_UPDATE_FAILED"),
        ) from exc

    return {
        "message": "Profile updated successfully",
        "user": serialize_user(updated),
    }


@app.get("/api/doctor-application/status")
def get_doctor_application_status(doctor=Depends(require_role("doctor"))):
    profile = get_doctor_profile(doctor["id"])
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Doctor profile not found", "DOCTOR_PROFILE_NOT_FOUND"),
        )
    return {
        "doctorId": doctor["id"],
        "approvalStatus": profile["approval_status"],
    }


@app.get("/api/admin/doctor-applications")
def get_admin_doctor_applications(
    approvalStatus: Optional[str] = Query(default=None),
    _=Depends(require_admin_key),
):
    if approvalStatus and approvalStatus not in {"approved", "pending", "rejected"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response("Unsupported approval status filter", "INVALID_APPROVAL_STATUS"),
        )
    items = [serialize_user(item) for item in list_doctor_applications(approvalStatus)]
    return {"items": items, "count": len(items)}


@app.patch("/api/admin/doctor-applications/{doctor_id}")
def patch_admin_doctor_application(
    doctor_id: str,
    payload: DoctorApplicationDecisionRequest,
    _=Depends(require_admin_key),
):
    doctor = get_user_by_id(doctor_id)
    if not doctor or doctor["role"] != "doctor":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Doctor not found", "DOCTOR_NOT_FOUND"),
        )

    try:
        updated = update_doctor_approval_status(doctor_id, payload.approvalStatus)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "DOCTOR_APPLICATION_UPDATE_FAILED"),
        ) from exc

    return {
        "message": "Doctor application status updated successfully",
        "doctor": serialize_user(updated),
    }


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


@app.get("/api/doctors/{doctor_id}/reviews")
def get_doctor_reviews(doctor_id: str):
    doctor = get_doctor_profile(doctor_id)
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Doctor not found", "DOCTOR_NOT_FOUND"),
        )
    return {"items": [serialize_review(item) for item in list_reviews_for_doctor(doctor_id)]}


@app.get("/api/search")
def search_catalog(
    query: Optional[str] = Query(default=None, min_length=1),
    specialization: Optional[str] = Query(default=None),
):
    doctors = [serialize_doctor(item) for item in list_doctors(search=query, specialization=specialization)]
    return {
        "query": query,
        "specialization": specialization,
        "doctors": doctors,
        "count": len(doctors),
    }


@app.get("/api/doctor/dashboard-summary")
def get_doctor_dashboard(doctor=Depends(require_role("doctor"))):
    return get_doctor_dashboard_summary(doctor["id"])


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


@app.get("/api/notifications")
def get_notifications(current_user=Depends(get_current_user)):
    notifications = [serialize_notification(item) for item in list_notifications_for_user(current_user["id"])]
    unread_count = sum(1 for item in notifications if not item["isRead"])
    return {"items": notifications, "unreadCount": unread_count}


@app.patch("/api/notifications/{notification_id}/read")
def patch_notification_read(notification_id: str, current_user=Depends(get_current_user)):
    notification = mark_notification_read(notification_id, current_user["id"])
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Notification not found", "NOTIFICATION_NOT_FOUND"),
        )
    return {
        "message": "Notification marked as read",
        "notification": serialize_notification(notification),
    }


@app.post("/api/support/contact")
def submit_contact_message(
    payload: ContactSubmissionRequest,
    current_user=Depends(get_current_user),
):
    submission = create_contact_submission(
        user_id=current_user["id"],
        name=current_user["full_name"],
        email=current_user["email"],
        subject=payload.subject,
        message=payload.message,
    )
    return {
        "message": "Support request submitted successfully",
        "submissionId": submission["id"],
        "status": submission["status"],
        "createdAt": submission["created_at"],
    }


@app.get("/api/wishlist")
def get_wishlist(patient=Depends(require_role("patient"))):
    items = [serialize_wishlist_item(item) for item in list_wishlist_for_patient(patient["id"])]
    return {"items": items}


@app.post("/api/wishlist/{doctor_id}")
def add_wishlist_item(doctor_id: str, patient=Depends(require_role("patient"))):
    try:
        item = add_doctor_to_wishlist(patient["id"], doctor_id)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "WISHLIST_ADD_FAILED"),
        ) from exc

    return {
        "message": "Doctor added to wishlist",
        "item": serialize_wishlist_item(item),
    }


@app.delete("/api/wishlist/{doctor_id}")
def remove_wishlist_item(doctor_id: str, patient=Depends(require_role("patient"))):
    removed = remove_doctor_from_wishlist(patient["id"], doctor_id)
    if not removed:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error_response("Wishlist item not found", "WISHLIST_NOT_FOUND"),
        )
    return {"message": "Doctor removed from wishlist"}


@app.get("/api/wallet/doctor")
def get_doctor_wallet(doctor=Depends(require_role("doctor"))):
    transactions = [
        serialize_wallet_transaction(item)
        for item in list_wallet_transactions_for_doctor(doctor["id"])
    ]
    summary = get_doctor_dashboard_summary(doctor["id"])
    return {
        "summary": {
            "pendingBalance": summary["pendingBalance"],
            "availableBalance": summary["availableBalance"],
            "canceledAmount": summary["canceledAmount"],
            "transactionCount": summary["transactionCount"],
        },
        "items": transactions,
    }


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


@app.post("/api/sessions/{session_id}/start")
def start_session_endpoint(
    session_id: str,
    payload: SessionStartRequest,
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
            detail=error_response("You cannot start this session", "FORBIDDEN"),
        )

    try:
        started = start_session(session_id, payload.startedAt)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "SESSION_START_FAILED"),
        ) from exc

    return {
        "message": "Session started",
        "sessionId": session_id,
        "status": "in_progress",
        "startedAt": started.get("started_at"),
    }


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


@app.post("/api/sessions/{session_id}/review")
def post_session_review(
    session_id: str,
    payload: ReviewRequest,
    patient=Depends(require_role("patient")),
):
    try:
        review = submit_session_review(
            session_id=session_id,
            patient_id=patient["id"],
            rating=payload.rating,
            comment=payload.comment,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_response(str(exc), "REVIEW_SUBMIT_FAILED"),
        ) from exc

    return {
        "message": "Review submitted successfully",
        "review": serialize_review(review),
    }


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


@app.get("/api/ai/patient-summary")
def get_patient_ai_summary(
    exercise: str = Query(..., min_length=2),
    patient=Depends(require_role("patient")),
):
    results = list_ai_results_for_patient_exercise(patient["id"], exercise)
    items = [serialize_ai_result(item) for item in results]
    latest = items[-1] if items else None
    return {
        "exercise": exercise,
        "patientId": patient["id"],
        "count": len(items),
        "latest": latest,
        "items": items,
    }


@app.get("/api/reviews/patient")
def get_patient_reviews(patient=Depends(require_role("patient"))):
    return {"items": [serialize_review(item) for item in list_reviews_for_patient(patient["id"])]}
