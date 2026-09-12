import hashlib
import secrets
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.config import get_settings
from app.core.rate_limit import enforce_rate_limit
from app.db.session import get_db
from app.models.identity import Group, GroupMember, User
from app.schemas.groups import (
    CreateGroupRequest,
    GroupCreatedResponse,
    GroupJoinCodeResponse,
    GroupSummary,
    JoinGroupRequest,
)

router = APIRouter(prefix="/api/v1/groups", tags=["groups"])


def _hash_join_code(join_code: str) -> str:
    return hashlib.sha256(join_code.encode("utf-8")).hexdigest()


def _new_join_code(db: Session) -> tuple[str, str]:
    for _ in range(5):
        join_code = secrets.token_urlsafe(12)
        join_code_hash = _hash_join_code(join_code)
        exists = db.scalar(select(Group.id).where(Group.join_code_hash == join_code_hash))
        if exists is None:
            return join_code, join_code_hash
    raise HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail="Could not allocate a group join code",
    )


def _summary(group: Group, role: str) -> GroupSummary:
    return GroupSummary(
        id=group.id,
        name=group.name,
        role=role,
        created_at=group.created_at,
    )


def _owned_group(db: Session, group_id: UUID, user_id: UUID) -> Group:
    group = db.scalar(
        select(Group).where(
            Group.id == group_id,
            Group.created_by == user_id,
        )
    )
    if group is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found",
        )
    return group


@router.post("", response_model=GroupCreatedResponse, status_code=status.HTTP_201_CREATED)
def create_group(
    request: CreateGroupRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> GroupCreatedResponse:
    settings = get_settings()
    enforce_rate_limit(
        enabled=settings.rate_limit_enabled,
        scope="group-create",
        subject=str(user.id),
        max_requests=settings.rate_limit_group_create_max_requests,
        window_seconds=settings.rate_limit_window_seconds,
    )

    join_code, join_code_hash = _new_join_code(db)
    group = Group(name=request.name, join_code_hash=join_code_hash, created_by=user.id)
    db.add(group)
    db.flush()
    db.add(GroupMember(group_id=group.id, user_id=user.id, role="owner"))
    db.commit()
    db.refresh(group)

    return GroupCreatedResponse(
        **_summary(group, "owner").model_dump(),
        join_code=join_code,
    )


@router.post("/join", response_model=GroupSummary)
def join_group(
    request: JoinGroupRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> GroupSummary:
    settings = get_settings()
    enforce_rate_limit(
        enabled=settings.rate_limit_enabled,
        scope="group-join",
        subject=str(user.id),
        max_requests=settings.rate_limit_join_max_requests,
        window_seconds=settings.rate_limit_window_seconds,
    )

    group = db.scalar(
        select(Group).where(Group.join_code_hash == _hash_join_code(request.join_code))
    )
    if group is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Invalid join code")

    membership = db.scalar(
        select(GroupMember).where(
            GroupMember.group_id == group.id,
            GroupMember.user_id == user.id,
        )
    )
    if membership is None:
        membership = GroupMember(group_id=group.id, user_id=user.id, role="member")
        db.add(membership)
        db.commit()

    return _summary(group, membership.role)


@router.post("/{group_id}/join-code/rotate", response_model=GroupJoinCodeResponse)
def rotate_join_code(
    group_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> GroupJoinCodeResponse:
    group = _owned_group(db, group_id, user.id)
    join_code, join_code_hash = _new_join_code(db)
    group.join_code_hash = join_code_hash
    db.commit()
    return GroupJoinCodeResponse(join_code=join_code)


@router.delete("/{group_id}/join-code", status_code=status.HTTP_204_NO_CONTENT)
def revoke_join_code(
    group_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    group = _owned_group(db, group_id, user.id)
    group.join_code_hash = None
    db.commit()


@router.get("", response_model=list[GroupSummary])
def list_groups(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[GroupSummary]:
    rows = db.execute(
        select(Group, GroupMember.role)
        .join(GroupMember, GroupMember.group_id == Group.id)
        .where(GroupMember.user_id == user.id)
        .order_by(Group.created_at.desc())
    ).all()
    return [_summary(group, role) for group, role in rows]


@router.get("/{group_id}", response_model=GroupSummary)
def get_group(
    group_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> GroupSummary:
    row = db.execute(
        select(Group, GroupMember.role)
        .join(GroupMember, GroupMember.group_id == Group.id)
        .where(Group.id == group_id, GroupMember.user_id == user.id)
    ).one_or_none()
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    group, role = row
    return _summary(group, role)
