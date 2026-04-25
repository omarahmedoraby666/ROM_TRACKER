from __future__ import annotations

import hashlib
import json
import sqlite3
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional


BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
DB_PATH = DATA_DIR / "rom_tracker.sqlite3"


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


def make_id(prefix: str) -> str:
    return f"{prefix}_{uuid.uuid4().hex[:10]}"


def get_connection() -> sqlite3.Connection:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON;")
    return connection


def initialize_database() -> None:
    with get_connection() as connection:
        connection.executescript(
            """
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                role TEXT NOT NULL CHECK(role IN ('patient', 'doctor')),
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                full_name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL,
                phone_code TEXT,
                phone_number TEXT,
                country TEXT,
                gender TEXT,
                avatar_url TEXT,
                created_at TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS doctor_profiles (
                user_id TEXT PRIMARY KEY,
                specialization TEXT NOT NULL,
                clinic_address TEXT NOT NULL,
                experience_years INTEGER NOT NULL,
                session_price INTEGER NOT NULL,
                bio TEXT NOT NULL,
                rating REAL NOT NULL DEFAULT 4.8,
                approval_status TEXT NOT NULL DEFAULT 'approved',
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS slots (
                id TEXT PRIMARY KEY,
                doctor_id TEXT NOT NULL,
                scheduled_at TEXT NOT NULL,
                display_time TEXT NOT NULL,
                is_booked INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS sessions (
                id TEXT PRIMARY KEY,
                patient_id TEXT NOT NULL,
                doctor_id TEXT NOT NULL,
                slot_id TEXT NOT NULL UNIQUE,
                status TEXT NOT NULL CHECK(status IN ('upcoming', 'completed', 'canceled')),
                reason TEXT NOT NULL,
                scheduled_at TEXT NOT NULL,
                display_time TEXT NOT NULL,
                patient_age INTEGER,
                patient_gender TEXT,
                doctor_notes TEXT,
                review TEXT,
                review_rating INTEGER,
                payment_status TEXT NOT NULL DEFAULT 'paid',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (slot_id) REFERENCES slots(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS ai_results (
                id TEXT PRIMARY KEY,
                session_id TEXT NOT NULL UNIQUE,
                patient_id TEXT NOT NULL,
                doctor_id TEXT NOT NULL,
                exercise TEXT NOT NULL,
                reps INTEGER NOT NULL,
                captured_at TEXT NOT NULL,
                raw_payload TEXT,
                report_title TEXT NOT NULL,
                report_summary TEXT NOT NULL,
                performance_level TEXT NOT NULL,
                recommendations TEXT NOT NULL,
                report_metrics TEXT NOT NULL DEFAULT '{}',
                created_at TEXT NOT NULL,
                FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
                FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE CASCADE
            );
            """
        )
        ensure_migrations(connection)
        seed_database(connection)


def ensure_migrations(connection: sqlite3.Connection) -> None:
    ai_columns = {
        row["name"]
        for row in connection.execute("PRAGMA table_info(ai_results)").fetchall()
    }
    if "report_metrics" not in ai_columns:
        connection.execute(
            "ALTER TABLE ai_results ADD COLUMN report_metrics TEXT NOT NULL DEFAULT '{}'"
        )
        connection.commit()


def seed_database(connection: sqlite3.Connection) -> None:
    existing = connection.execute("SELECT COUNT(*) AS count FROM users").fetchone()["count"]
    if existing:
        return

    created_at = now_iso()

    users = [
        {
            "id": "user_patient_001",
            "role": "patient",
            "first_name": "Gamal",
            "last_name": "Ali",
            "full_name": "Gamal Ali",
            "email": "patient@app.com",
            "password_hash": hash_password("123456"),
            "phone_code": "+20",
            "phone_number": "1012345678",
            "country": "Egypt",
            "gender": "Male",
            "avatar_url": None,
        },
        {
            "id": "user_doctor_001",
            "role": "doctor",
            "first_name": "Mohamed",
            "last_name": "Alaa",
            "full_name": "Mohamed Alaa",
            "email": "doctor@app.com",
            "password_hash": hash_password("123456"),
            "phone_code": "+20",
            "phone_number": "1098765432",
            "country": "Egypt",
            "gender": "Male",
            "avatar_url": None,
        },
        {
            "id": "user_doctor_002",
            "role": "doctor",
            "first_name": "Sara",
            "last_name": "Ali",
            "full_name": "Sara Ali",
            "email": "sara.doctor@app.com",
            "password_hash": hash_password("123456"),
            "phone_code": "+20",
            "phone_number": "1000000002",
            "country": "Egypt",
            "gender": "Female",
            "avatar_url": None,
        },
        {
            "id": "user_doctor_003",
            "role": "doctor",
            "first_name": "Lina",
            "last_name": "Mostafa",
            "full_name": "Lina Mostafa",
            "email": "lina.doctor@app.com",
            "password_hash": hash_password("123456"),
            "phone_code": "+20",
            "phone_number": "1000000003",
            "country": "Egypt",
            "gender": "Female",
            "avatar_url": None,
        },
        {
            "id": "user_doctor_004",
            "role": "doctor",
            "first_name": "Ahmed",
            "last_name": "Hassan",
            "full_name": "Ahmed Hassan",
            "email": "ahmed.doctor@app.com",
            "password_hash": hash_password("123456"),
            "phone_code": "+20",
            "phone_number": "1000000004",
            "country": "Egypt",
            "gender": "Male",
            "avatar_url": None,
        },
    ]

    connection.executemany(
        """
        INSERT INTO users (
            id, role, first_name, last_name, full_name, email, password_hash,
            phone_code, phone_number, country, gender, avatar_url, created_at
        ) VALUES (
            :id, :role, :first_name, :last_name, :full_name, :email, :password_hash,
            :phone_code, :phone_number, :country, :gender, :avatar_url, :created_at
        )
        """,
        [{**user, "created_at": created_at} for user in users],
    )

    doctor_profiles = [
        {
            "user_id": "user_doctor_001",
            "specialization": "Physical Therapist",
            "clinic_address": "Active Care Physiotherapy Center Cairo",
            "experience_years": 7,
            "session_price": 350,
            "bio": "Specialized in knee and post-injury rehabilitation with a focus on movement quality.",
            "rating": 4.9,
            "approval_status": "approved",
        },
        {
            "user_id": "user_doctor_002",
            "specialization": "Sports Rehabilitation",
            "clinic_address": "Cairo Sports Rehab Clinic",
            "experience_years": 5,
            "session_price": 320,
            "bio": "Works with athletic recovery programs and progressive strength restoration.",
            "rating": 4.7,
            "approval_status": "approved",
        },
        {
            "user_id": "user_doctor_003",
            "specialization": "Neurological Physiotherapy",
            "clinic_address": "Neuro Motion Center Giza",
            "experience_years": 6,
            "session_price": 340,
            "bio": "Focuses on balance, gait recovery, and long-term neurological movement support.",
            "rating": 4.8,
            "approval_status": "approved",
        },
        {
            "user_id": "user_doctor_004",
            "specialization": "Orthopedic Rehabilitation",
            "clinic_address": "Ortho Move Clinic Alexandria",
            "experience_years": 8,
            "session_price": 360,
            "bio": "Helps patients recover safely after orthopedic surgery and mobility limitations.",
            "rating": 4.85,
            "approval_status": "approved",
        },
    ]

    connection.executemany(
        """
        INSERT INTO doctor_profiles (
            user_id, specialization, clinic_address, experience_years,
            session_price, bio, rating, approval_status
        ) VALUES (
            :user_id, :specialization, :clinic_address, :experience_years,
            :session_price, :bio, :rating, :approval_status
        )
        """,
        doctor_profiles,
    )

    doctor_ids = [profile["user_id"] for profile in doctor_profiles]
    slots = []
    base = datetime.now(timezone.utc).replace(minute=30, second=0, microsecond=0) + timedelta(days=1)
    for index, doctor_id in enumerate(doctor_ids):
        for slot_offset in range(4):
            scheduled = base + timedelta(days=index + slot_offset, hours=slot_offset * 2)
            display = scheduled.strftime("%a %d - %I:%M %p").lower()
            slots.append(
                {
                    "id": f"slot_{doctor_id[-3:]}_{slot_offset + 1}",
                    "doctor_id": doctor_id,
                    "scheduled_at": scheduled.isoformat().replace("+00:00", "Z"),
                    "display_time": display,
                    "is_booked": 0,
                }
            )

    connection.executemany(
        """
        INSERT INTO slots (id, doctor_id, scheduled_at, display_time, is_booked)
        VALUES (:id, :doctor_id, :scheduled_at, :display_time, :is_booked)
        """,
        slots,
    )

    connection.commit()


def row_to_dict(row: Optional[sqlite3.Row]) -> Optional[Dict[str, Any]]:
    return dict(row) if row else None


def rows_to_dicts(rows: Iterable[sqlite3.Row]) -> List[Dict[str, Any]]:
    return [dict(row) for row in rows]


def get_user_by_email(email: str) -> Optional[Dict[str, Any]]:
    with get_connection() as connection:
        row = connection.execute("SELECT * FROM users WHERE email = ?", (email.lower(),)).fetchone()
        return row_to_dict(row)


def get_user_by_id(user_id: str) -> Optional[Dict[str, Any]]:
    with get_connection() as connection:
        row = connection.execute("SELECT * FROM users WHERE id = ?", (user_id,)).fetchone()
        return row_to_dict(row)


def create_patient_account(
    *,
    first_name: str,
    last_name: str,
    email: str,
    password: str,
    phone_code: Optional[str],
    phone_number: Optional[str],
    country: Optional[str],
    gender: Optional[str],
) -> Dict[str, Any]:
    user_id = make_id("user")
    created_at = now_iso()
    full_name = f"{first_name.strip()} {last_name.strip()}"

    with get_connection() as connection:
        existing = connection.execute(
            "SELECT id FROM users WHERE email = ?",
            (email.lower(),),
        ).fetchone()
        if existing:
            raise ValueError("Email already exists")

        connection.execute(
            """
            INSERT INTO users (
                id, role, first_name, last_name, full_name, email, password_hash,
                phone_code, phone_number, country, gender, avatar_url, created_at
            ) VALUES (?, 'patient', ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?)
            """,
            (
                user_id,
                first_name.strip(),
                last_name.strip(),
                full_name,
                email.lower(),
                hash_password(password),
                phone_code,
                phone_number,
                country,
                gender,
                created_at,
            ),
        )
        connection.commit()

    return get_user_by_id(user_id)


def create_doctor_account(
    *,
    first_name: str,
    last_name: str,
    email: str,
    password: str,
    phone_code: Optional[str],
    phone_number: Optional[str],
    country: Optional[str],
    gender: Optional[str],
    specialization: str,
    clinic_address: str,
    experience_years: int,
    session_price: int,
    bio: str,
) -> Dict[str, Any]:
    user_id = make_id("user")
    created_at = now_iso()
    full_name = f"{first_name.strip()} {last_name.strip()}"

    with get_connection() as connection:
        existing = connection.execute(
            "SELECT id FROM users WHERE email = ?",
            (email.lower(),),
        ).fetchone()
        if existing:
            raise ValueError("Email already exists")

        connection.execute(
            """
            INSERT INTO users (
                id, role, first_name, last_name, full_name, email, password_hash,
                phone_code, phone_number, country, gender, avatar_url, created_at
            ) VALUES (?, 'doctor', ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?)
            """,
            (
                user_id,
                first_name.strip(),
                last_name.strip(),
                full_name,
                email.lower(),
                hash_password(password),
                phone_code,
                phone_number,
                country,
                gender,
                created_at,
            ),
        )

        connection.execute(
            """
            INSERT INTO doctor_profiles (
                user_id, specialization, clinic_address, experience_years,
                session_price, bio, rating, approval_status
            ) VALUES (?, ?, ?, ?, ?, ?, 0, 'pending')
            """,
            (
                user_id,
                specialization.strip(),
                clinic_address.strip(),
                experience_years,
                session_price,
                bio.strip(),
            ),
        )
        connection.commit()

    doctor = get_doctor_profile(user_id)
    if not doctor:
        raise ValueError("Doctor account was created but could not be loaded")
    return doctor


def get_doctor_profile(user_id: str) -> Optional[Dict[str, Any]]:
    with get_connection() as connection:
        row = connection.execute(
            """
            SELECT u.*, dp.specialization, dp.clinic_address, dp.experience_years,
                   dp.session_price, dp.bio, dp.rating, dp.approval_status
            FROM users u
            JOIN doctor_profiles dp ON dp.user_id = u.id
            WHERE u.id = ? AND u.role = 'doctor'
            """,
            (user_id,),
        ).fetchone()
        return row_to_dict(row)


def list_doctors(search: Optional[str] = None, specialization: Optional[str] = None) -> List[Dict[str, Any]]:
    query = """
        SELECT u.*, dp.specialization, dp.clinic_address, dp.experience_years,
               dp.session_price, dp.bio, dp.rating, dp.approval_status
        FROM users u
        JOIN doctor_profiles dp ON dp.user_id = u.id
        WHERE u.role = 'doctor' AND dp.approval_status = 'approved'
    """
    params: List[Any] = []
    if search:
        query += " AND (u.full_name LIKE ? OR dp.specialization LIKE ?)"
        wildcard = f"%{search}%"
        params.extend([wildcard, wildcard])
    if specialization:
        query += " AND dp.specialization LIKE ?"
        params.append(f"%{specialization}%")
    query += " ORDER BY dp.rating DESC, u.full_name ASC"

    with get_connection() as connection:
        rows = connection.execute(query, params).fetchall()
        return rows_to_dicts(rows)


def list_slots_for_doctor(doctor_id: str) -> List[Dict[str, Any]]:
    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT id, doctor_id, scheduled_at, display_time, is_booked
            FROM slots
            WHERE doctor_id = ?
            ORDER BY scheduled_at ASC
            """,
            (doctor_id,),
        ).fetchall()
        return rows_to_dicts(rows)


def get_slot(slot_id: str) -> Optional[Dict[str, Any]]:
    with get_connection() as connection:
        row = connection.execute("SELECT * FROM slots WHERE id = ?", (slot_id,)).fetchone()
        return row_to_dict(row)


def get_session(session_id: str) -> Optional[Dict[str, Any]]:
    with get_connection() as connection:
        row = connection.execute(
            """
            SELECT s.*, p.full_name AS patient_name, d.full_name AS doctor_name,
                   dp.specialization AS specialty
            FROM sessions s
            JOIN users p ON p.id = s.patient_id
            JOIN users d ON d.id = s.doctor_id
            JOIN doctor_profiles dp ON dp.user_id = s.doctor_id
            WHERE s.id = ?
            """,
            (session_id,),
        ).fetchone()
        return row_to_dict(row)


def create_booking(
    *,
    patient_id: str,
    doctor_id: str,
    slot_id: str,
    reason: str,
    patient_age: Optional[int],
    patient_gender: Optional[str],
) -> Dict[str, Any]:
    slot = get_slot(slot_id)
    if not slot:
        raise ValueError("Selected slot was not found")
    if slot["doctor_id"] != doctor_id:
        raise ValueError("Selected slot does not belong to the requested doctor")
    if slot["is_booked"]:
        raise ValueError("Selected slot is already booked")

    session_id = make_id("session")
    timestamp = now_iso()

    with get_connection() as connection:
        connection.execute(
            """
            INSERT INTO sessions (
                id, patient_id, doctor_id, slot_id, status, reason,
                scheduled_at, display_time, patient_age, patient_gender,
                doctor_notes, review, review_rating, payment_status,
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, 'upcoming', ?, ?, ?, ?, ?, '', NULL, NULL, 'paid', ?, ?)
            """,
            (
                session_id,
                patient_id,
                doctor_id,
                slot_id,
                reason,
                slot["scheduled_at"],
                slot["display_time"],
                patient_age,
                patient_gender,
                timestamp,
                timestamp,
            ),
        )
        connection.execute("UPDATE slots SET is_booked = 1 WHERE id = ?", (slot_id,))
        connection.commit()

    session = get_session(session_id)
    if not session:
        raise ValueError("Booking was created but could not be loaded")
    return session


def list_sessions_for_patient(patient_id: str) -> List[Dict[str, Any]]:
    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT s.*, p.full_name AS patient_name, d.full_name AS doctor_name,
                   dp.specialization AS specialty
            FROM sessions s
            JOIN users p ON p.id = s.patient_id
            JOIN users d ON d.id = s.doctor_id
            JOIN doctor_profiles dp ON dp.user_id = s.doctor_id
            WHERE s.patient_id = ?
            ORDER BY s.scheduled_at DESC
            """,
            (patient_id,),
        ).fetchall()
        return rows_to_dicts(rows)


def list_sessions_for_doctor(doctor_id: str) -> List[Dict[str, Any]]:
    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT s.*, p.full_name AS patient_name, d.full_name AS doctor_name,
                   dp.specialization AS specialty
            FROM sessions s
            JOIN users p ON p.id = s.patient_id
            JOIN users d ON d.id = s.doctor_id
            JOIN doctor_profiles dp ON dp.user_id = s.doctor_id
            WHERE s.doctor_id = ?
            ORDER BY s.scheduled_at DESC
            """,
            (doctor_id,),
        ).fetchall()
        return rows_to_dicts(rows)


def update_session_status(
    *,
    session_id: str,
    status: str,
    doctor_notes: Optional[str],
    review: Optional[str],
    review_rating: Optional[int],
) -> Dict[str, Any]:
    existing = get_session(session_id)
    if not existing:
        raise ValueError("Session not found")

    if status not in {"upcoming", "completed", "canceled"}:
        raise ValueError("Unsupported session status")

    updated_at = now_iso()
    with get_connection() as connection:
        connection.execute(
            """
            UPDATE sessions
            SET status = ?,
                doctor_notes = COALESCE(?, doctor_notes),
                review = COALESCE(?, review),
                review_rating = COALESCE(?, review_rating),
                updated_at = ?
            WHERE id = ?
            """,
            (status, doctor_notes, review, review_rating, updated_at, session_id),
        )

        if status == "canceled":
            connection.execute(
                """
                UPDATE slots
                SET is_booked = 0
                WHERE id = (SELECT slot_id FROM sessions WHERE id = ?)
                """,
                (session_id,),
            )

        if status == "upcoming":
            connection.execute(
                """
                UPDATE slots
                SET is_booked = 1
                WHERE id = (SELECT slot_id FROM sessions WHERE id = ?)
                """,
                (session_id,),
            )

        connection.commit()

    session = get_session(session_id)
    if not session:
        raise ValueError("Session was updated but could not be reloaded")
    return session


def generate_ai_report(exercise: str, reps: int) -> Dict[str, Any]:
    normalized = exercise.strip().lower()
    if reps >= 12:
        level = "excellent"
        summary = f"{exercise} performance was strong with {reps} valid repetitions."
        recommendations = [
            "Maintain the same pace and posture in the next session.",
            "Focus on consistent range of motion for every repetition.",
        ]
    elif reps >= 8:
        level = "good"
        summary = f"{exercise} performance was good with {reps} valid repetitions."
        recommendations = [
            "Aim for 2 to 4 more stable repetitions next session.",
            "Keep posture controlled during the middle range of movement.",
        ]
    elif reps >= 4:
        level = "needs_improvement"
        summary = f"{exercise} result shows partial completion with {reps} valid repetitions."
        recommendations = [
            "Reduce speed and prioritize correct form over count.",
            "Repeat with closer supervision if pain or instability appears.",
        ]
    else:
        level = "insufficient"
        summary = f"{exercise} result is limited with only {reps} valid repetitions recorded."
        recommendations = [
            "Reassess patient readiness before the next attempt.",
            "Use easier progression or supported movement in the next session.",
        ]

    if normalized == "squat":
        recommendations.append("Watch knee alignment and controlled descent during each squat.")
    elif normalized == "seated leg extension":
        recommendations.append("Aim for full extension without forcing hyperextension.")

    return {
        "title": f"{exercise} session report",
        "summary": summary,
        "performanceLevel": level,
        "recommendations": recommendations,
    }


def list_ai_results_for_patient_exercise(patient_id: str, exercise: str) -> List[Dict[str, Any]]:
    with get_connection() as connection:
        rows = connection.execute(
            """
            SELECT *
            FROM ai_results
            WHERE patient_id = ? AND LOWER(exercise) = LOWER(?)
            ORDER BY captured_at ASC, created_at ASC
            """,
            (patient_id, exercise),
        ).fetchall()

    results = []
    for row in rows_to_dicts(rows):
        row["raw_payload"] = json.loads(row["raw_payload"] or "{}")
        row["recommendations"] = json.loads(row["recommendations"] or "[]")
        row["report_metrics"] = json.loads(row.get("report_metrics") or "{}")
        results.append(row)
    return results


def build_ai_report_from_history(
    *,
    patient_id: str,
    exercise: str,
    reps: int,
    prior_results: List[Dict[str, Any]],
) -> Dict[str, Any]:
    normalized = exercise.strip().lower()
    previous_reps = prior_results[-1]["reps"] if prior_results else None
    all_reps = [item["reps"] for item in prior_results] + [reps]
    total_sessions = len(all_reps)
    total_reps = sum(all_reps)
    average_reps = round(total_reps / total_sessions, 2)
    best_reps = max(all_reps)
    latest_delta = reps - previous_reps if previous_reps is not None else None

    if previous_reps is None:
        trend = "first_record"
    elif reps > previous_reps:
        trend = "improved"
    elif reps < previous_reps:
        trend = "declined"
    else:
        trend = "stable"

    if average_reps >= 12:
        level = "excellent"
    elif average_reps >= 8:
        level = "good"
    elif average_reps >= 4:
        level = "needs_improvement"
    else:
        level = "insufficient"

    if trend == "first_record":
        summary = (
            f"This is the first recorded {exercise} result for the patient, "
            f"with {reps} valid repetitions."
        )
    else:
        direction = "higher" if latest_delta and latest_delta > 0 else "lower" if latest_delta and latest_delta < 0 else "unchanged"
        summary = (
            f"The patient now has {total_sessions} recorded {exercise} result(s). "
            f"The latest result is {reps} reps, which is {direction} than the previous recorded result. "
            f"The running average is {average_reps} reps and the best recorded result is {best_reps} reps."
        )

    recommendations = [
        "Use the recorded trend to guide the next exercise target rather than depending on a single result only.",
        "Compare the next session against both the average and the best recorded repetition count.",
    ]

    if trend == "improved":
        recommendations.append("The patient is improving. Consider a small progression while preserving safe form.")
    elif trend == "declined":
        recommendations.append("Performance declined versus the previous attempt. Re-check fatigue, pain, and technique.")
    elif trend == "stable":
        recommendations.append("Performance is stable. Focus on consistency and controlled execution before progressing.")
    else:
        recommendations.append("This is the baseline measurement for future comparison.")

    if normalized == "squat":
        recommendations.append("Track squat depth and knee alignment together with rep count in future sessions.")
    elif normalized == "seated leg extension":
        recommendations.append("Track terminal extension quality and avoid pushing into hyperextension.")

    metrics = {
        "totalRecordedSessions": total_sessions,
        "totalRecordedReps": total_reps,
        "averageReps": average_reps,
        "bestReps": best_reps,
        "previousReps": previous_reps,
        "latestReps": reps,
        "latestDelta": latest_delta,
        "trend": trend,
    }

    return {
        "title": f"{exercise} progress report",
        "summary": summary,
        "performanceLevel": level,
        "recommendations": recommendations,
        "metrics": metrics,
    }


def upsert_ai_result(
    *,
    session_id: str,
    exercise: str,
    reps: int,
    timestamp: str,
    raw_payload: Optional[Dict[str, Any]],
) -> Dict[str, Any]:
    session = get_session(session_id)
    if not session:
        raise ValueError("Session not found")

    prior_results = list_ai_results_for_patient_exercise(session["patient_id"], exercise)
    prior_results = [item for item in prior_results if item["session_id"] != session_id]
    report = build_ai_report_from_history(
        patient_id=session["patient_id"],
        exercise=exercise,
        reps=reps,
        prior_results=prior_results,
    )
    created_at = now_iso()
    existing = get_ai_result(session_id)

    with get_connection() as connection:
        if existing:
            connection.execute(
                """
                UPDATE ai_results
                SET exercise = ?,
                    reps = ?,
                    captured_at = ?,
                    raw_payload = ?,
                    report_title = ?,
                    report_summary = ?,
                    performance_level = ?,
                    recommendations = ?,
                    report_metrics = ?,
                    created_at = ?
                WHERE session_id = ?
                """,
                (
                    exercise,
                    reps,
                    timestamp,
                    json.dumps(raw_payload or {}),
                    report["title"],
                    report["summary"],
                    report["performanceLevel"],
                    json.dumps(report["recommendations"]),
                    json.dumps(report["metrics"]),
                    created_at,
                    session_id,
                ),
            )
        else:
            connection.execute(
                """
                INSERT INTO ai_results (
                    id, session_id, patient_id, doctor_id, exercise, reps,
                    captured_at, raw_payload, report_title, report_summary,
                    performance_level, recommendations, report_metrics, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    make_id("ai"),
                    session_id,
                    session["patient_id"],
                    session["doctor_id"],
                    exercise,
                    reps,
                    timestamp,
                    json.dumps(raw_payload or {}),
                    report["title"],
                    report["summary"],
                    report["performanceLevel"],
                    json.dumps(report["recommendations"]),
                    json.dumps(report["metrics"]),
                    created_at,
                ),
            )
        connection.commit()

    result = get_ai_result(session_id)
    if not result:
        raise ValueError("AI result could not be loaded after saving")
    return result


def get_ai_result(session_id: str) -> Optional[Dict[str, Any]]:
    with get_connection() as connection:
        row = connection.execute("SELECT * FROM ai_results WHERE session_id = ?", (session_id,)).fetchone()
        if not row:
            return None
        data = dict(row)
        data["raw_payload"] = json.loads(data["raw_payload"] or "{}")
        data["recommendations"] = json.loads(data["recommendations"] or "[]")
        data["report_metrics"] = json.loads(data.get("report_metrics") or "{}")
        return data
