from __future__ import annotations

import secrets
from typing import Dict, Optional

from fastapi import Depends, Header, HTTPException, status

from .database import get_user_by_id


TOKEN_REGISTRY: Dict[str, str] = {}


def issue_access_token(user_id: str) -> str:
    token = secrets.token_urlsafe(32)
    TOKEN_REGISTRY[token] = user_id
    return token


def _extract_bearer_token(authorization: Optional[str]) -> str:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
        )

    parts = authorization.split(" ", 1)
    if len(parts) != 2 or parts[0].lower() != "bearer" or not parts[1].strip():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid bearer token format",
        )

    return parts[1].strip()


def get_current_user(authorization: Optional[str] = Header(default=None)):
    token = _extract_bearer_token(authorization)
    user_id = TOKEN_REGISTRY.get(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return user


def require_role(expected_role: str):
    def dependency(user=Depends(get_current_user)):
        if user["role"] != expected_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"{expected_role.title()} access required",
            )
        return user

    return dependency
