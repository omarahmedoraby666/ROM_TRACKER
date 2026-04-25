from __future__ import annotations

from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class LoginRequest(BaseModel):
    email: str
    password: str = Field(min_length=6)


class RegisterPatientRequest(BaseModel):
    firstName: str = Field(min_length=2, max_length=50)
    lastName: str = Field(min_length=2, max_length=50)
    email: str
    password: str = Field(min_length=6, max_length=100)
    phoneCode: Optional[str] = "+20"
    phoneNumber: Optional[str] = None
    country: Optional[str] = "Egypt"
    gender: Optional[str] = None


class RegisterDoctorRequest(BaseModel):
    firstName: str = Field(min_length=2, max_length=50)
    lastName: str = Field(min_length=2, max_length=50)
    email: str
    password: str = Field(min_length=6, max_length=100)
    phoneCode: Optional[str] = "+20"
    phoneNumber: Optional[str] = None
    country: Optional[str] = "Egypt"
    gender: Optional[str] = None
    specialization: str = Field(min_length=2, max_length=100)
    clinicAddress: str = Field(min_length=3, max_length=150)
    experienceYears: int = Field(ge=0, le=60)
    sessionPrice: int = Field(ge=0, le=100000)
    bio: str = Field(min_length=10, max_length=400)


class BookingRequest(BaseModel):
    doctorId: str
    slotId: str
    reason: str = Field(min_length=3, max_length=200)
    patientAge: Optional[int] = Field(default=None, ge=1, le=120)
    patientGender: Optional[str] = None
    paymentMethod: Optional[str] = None


class SessionStatusRequest(BaseModel):
    status: str
    doctorNotes: Optional[str] = None
    review: Optional[str] = None
    reviewRating: Optional[int] = Field(default=None, ge=1, le=5)


class SessionStartRequest(BaseModel):
    startedAt: Optional[str] = None


class ReviewRequest(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: str = Field(min_length=2, max_length=500)


class AIResultRequest(BaseModel):
    exercise: str = Field(min_length=2, max_length=100)
    reps: int = Field(ge=0, le=10000)
    timestamp: str
    rawPayload: Optional[Dict[str, Any]] = None


class MessageResponse(BaseModel):
    message: str


class DoctorItem(BaseModel):
    id: str
    fullName: str
    email: str
    avatarUrl: Optional[str] = None
    specialization: str
    clinicAddress: str
    experienceYears: int
    sessionPrice: int
    bio: str
    rating: float


class DoctorsListResponse(BaseModel):
    items: List[DoctorItem]


class SlotItem(BaseModel):
    id: str
    doctorId: str
    scheduledAt: str
    displayTime: str
    isBooked: bool


class SlotsResponse(BaseModel):
    items: List[SlotItem]
