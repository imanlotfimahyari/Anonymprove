import re
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import delete, func, or_, select
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.db.session import get_db
from app.models.feedback import Question, Questionnaire, QuestionOption
from app.models.identity import GroupMember, User
from app.schemas.feedback import QuestionnaireSummary, QuestionOptionSummary, QuestionSummary
from app.schemas.questionnaires import QuestionnaireUpsertRequest

router = APIRouter(prefix="/api/v1", tags=["questionnaires"])


def _membership(db: Session, group_id: UUID, user_id: UUID) -> GroupMember | None:
    return db.scalar(
        select(GroupMember).where(
            GroupMember.group_id == group_id,
            GroupMember.user_id == user_id,
        )
    )


def _require_membership(db: Session, group_id: UUID, user_id: UUID) -> None:
    if _membership(db, group_id, user_id) is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")


def _options(db: Session, question_id: UUID) -> list[QuestionOption]:
    return list(
        db.scalars(
            select(QuestionOption)
            .where(QuestionOption.question_id == question_id)
            .order_by(QuestionOption.position)
        ).all()
    )


def _question_summary(db: Session, question: Question) -> QuestionSummary:
    return QuestionSummary(
        id=question.id,
        key=question.key,
        prompt=question.prompt,
        kind=question.kind,
        position=question.position,
        required=question.required,
        min_score=question.min_score,
        max_score=question.max_score,
        options=[
            QuestionOptionSummary(id=option.id, label=option.label, position=option.position)
            for option in _options(db, question.id)
        ],
    )


def _summary(db: Session, questionnaire: Questionnaire) -> QuestionnaireSummary:
    questions = db.scalars(
        select(Question)
        .where(Question.questionnaire_id == questionnaire.id)
        .order_by(Question.position)
    ).all()
    return QuestionnaireSummary(
        id=questionnaire.id,
        group_id=questionnaire.group_id,
        created_by_user_id=questionnaire.created_by_user_id,
        slug=questionnaire.slug,
        name=questionnaire.name,
        description=questionnaire.description,
        version=questionnaire.version,
        status=questionnaire.status,
        questions=[_question_summary(db, question) for question in questions],
    )


def _questionnaire_for_group(db: Session, group_id: UUID, questionnaire_id: UUID) -> Questionnaire:
    questionnaire = db.scalar(
        select(Questionnaire).where(
            Questionnaire.id == questionnaire_id,
            or_(Questionnaire.group_id.is_(None), Questionnaire.group_id == group_id),
        )
    )
    if questionnaire is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Questionnaire not found")
    return questionnaire


def _owned_custom_questionnaire(
    db: Session, group_id: UUID, questionnaire_id: UUID, user_id: UUID
) -> Questionnaire:
    questionnaire = db.scalar(
        select(Questionnaire).where(
            Questionnaire.id == questionnaire_id,
            Questionnaire.group_id == group_id,
            Questionnaire.created_by_user_id == user_id,
        )
    )
    if questionnaire is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Questionnaire is not editable"
        )
    return questionnaire


def _new_slug(db: Session, name: str) -> str:
    base = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")[:40] or "questionnaire"
    for _ in range(5):
        slug = f"{base}-{uuid4().hex[:8]}"
        exists = db.scalar(select(Questionnaire.id).where(Questionnaire.slug == slug))
        if exists is None:
            return slug
    raise HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail="Could not allocate questionnaire identifier",
    )


def _replace_questions(
    db: Session, questionnaire_id: UUID, request: QuestionnaireUpsertRequest
) -> None:
    question_ids = list(
        db.scalars(select(Question.id).where(Question.questionnaire_id == questionnaire_id)).all()
    )
    if question_ids:
        db.execute(delete(QuestionOption).where(QuestionOption.question_id.in_(question_ids)))
        db.execute(delete(Question).where(Question.id.in_(question_ids)))
        db.flush()

    for position, item in enumerate(request.questions, start=1):
        question = Question(
            questionnaire_id=questionnaire_id,
            key=f"q{position}",
            prompt=item.prompt,
            kind=item.kind,
            position=position,
            required=item.required,
            min_score=item.min_score,
            max_score=item.max_score,
        )
        db.add(question)
        db.flush()
        db.add_all(
            QuestionOption(question_id=question.id, label=label, position=option_position)
            for option_position, label in enumerate(item.options, start=1)
        )


@router.post(
    "/groups/{group_id}/questionnaires",
    response_model=QuestionnaireSummary,
    status_code=status.HTTP_201_CREATED,
)
def create_questionnaire(
    group_id: UUID,
    request: QuestionnaireUpsertRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> QuestionnaireSummary:
    _require_membership(db, group_id, user.id)
    questionnaire = Questionnaire(
        group_id=group_id,
        created_by_user_id=user.id,
        slug=_new_slug(db, request.name),
        name=request.name,
        description=request.description,
        version=1,
        status="draft",
    )
    db.add(questionnaire)
    db.flush()
    _replace_questions(db, questionnaire.id, request)
    db.commit()
    db.refresh(questionnaire)
    return _summary(db, questionnaire)


@router.get(
    "/groups/{group_id}/questionnaires",
    response_model=list[QuestionnaireSummary],
)
def list_questionnaires(
    group_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[QuestionnaireSummary]:
    _require_membership(db, group_id, user.id)
    questionnaires = db.scalars(
        select(Questionnaire)
        .where(
            or_(
                Questionnaire.group_id == group_id,
                (Questionnaire.group_id.is_(None) & (Questionnaire.status == "published")),
            )
        )
        .order_by(Questionnaire.name, Questionnaire.version.desc())
    ).all()
    return [_summary(db, questionnaire) for questionnaire in questionnaires]


@router.get(
    "/groups/{group_id}/questionnaires/{questionnaire_id}",
    response_model=QuestionnaireSummary,
)
def get_questionnaire(
    group_id: UUID,
    questionnaire_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> QuestionnaireSummary:
    _require_membership(db, group_id, user.id)
    return _summary(db, _questionnaire_for_group(db, group_id, questionnaire_id))


@router.put(
    "/groups/{group_id}/questionnaires/{questionnaire_id}",
    response_model=QuestionnaireSummary,
)
def update_questionnaire(
    group_id: UUID,
    questionnaire_id: UUID,
    request: QuestionnaireUpsertRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> QuestionnaireSummary:
    _require_membership(db, group_id, user.id)
    questionnaire = _owned_custom_questionnaire(db, group_id, questionnaire_id, user.id)
    if questionnaire.status != "draft":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Published questionnaires are immutable; create a new version instead",
        )
    questionnaire.name = request.name
    questionnaire.description = request.description
    _replace_questions(db, questionnaire.id, request)
    db.commit()
    return _summary(db, questionnaire)


@router.post(
    "/groups/{group_id}/questionnaires/{questionnaire_id}/publish",
    response_model=QuestionnaireSummary,
)
def publish_questionnaire(
    group_id: UUID,
    questionnaire_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> QuestionnaireSummary:
    _require_membership(db, group_id, user.id)
    questionnaire = _owned_custom_questionnaire(db, group_id, questionnaire_id, user.id)
    if questionnaire.status != "draft":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, detail="Questionnaire is already published"
        )
    answerable_count = db.scalar(
        select(func.count())
        .select_from(Question)
        .where(
            Question.questionnaire_id == questionnaire.id,
            Question.kind != "description",
        )
    )
    if (answerable_count or 0) == 0:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="A published questionnaire must contain at least one answerable question",
        )
    questionnaire.status = "published"
    db.commit()
    return _summary(db, questionnaire)


@router.post(
    "/groups/{group_id}/questionnaires/{questionnaire_id}/versions",
    response_model=QuestionnaireSummary,
    status_code=status.HTTP_201_CREATED,
)
def create_questionnaire_version(
    group_id: UUID,
    questionnaire_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> QuestionnaireSummary:
    _require_membership(db, group_id, user.id)
    source = _owned_custom_questionnaire(db, group_id, questionnaire_id, user.id)
    if source.status != "published":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Only a published questionnaire can start a new version",
        )

    max_version = db.scalar(
        select(func.max(Questionnaire.version)).where(
            Questionnaire.slug == source.slug,
            Questionnaire.group_id == group_id,
        )
    )
    clone = Questionnaire(
        group_id=group_id,
        created_by_user_id=user.id,
        slug=source.slug,
        name=source.name,
        description=source.description,
        version=(max_version or source.version) + 1,
        status="draft",
    )
    db.add(clone)
    db.flush()

    source_questions = db.scalars(
        select(Question).where(Question.questionnaire_id == source.id).order_by(Question.position)
    ).all()
    for source_question in source_questions:
        cloned_question = Question(
            questionnaire_id=clone.id,
            key=source_question.key,
            prompt=source_question.prompt,
            kind=source_question.kind,
            position=source_question.position,
            required=source_question.required,
            min_score=source_question.min_score,
            max_score=source_question.max_score,
        )
        db.add(cloned_question)
        db.flush()
        db.add_all(
            QuestionOption(
                question_id=cloned_question.id,
                label=option.label,
                position=option.position,
            )
            for option in _options(db, source_question.id)
        )

    db.commit()
    db.refresh(clone)
    return _summary(db, clone)
