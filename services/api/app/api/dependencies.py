from fastapi import Depends
from sqlalchemy.orm import Session

from app.core.security import Principal, get_current_principal, unauthorized
from app.db.session import get_db
from app.models.identity import User


def get_current_user(
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
) -> User:
    user = db.get(User, principal.user_id)
    if user is None:
        raise unauthorized("Session not found")
    return user
