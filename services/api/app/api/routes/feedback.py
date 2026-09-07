import hashlib
import secrets
from datetime import UTC, datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.db.session import get_db
from app.models.feedback import (
    AnonymousResponse,
    Answer,
    CredentialClaim,
    FeedbackRound,
    Question,
    Questionnaire,
    ResponseCredential,
)
from app.models.identity import GroupMember, User
from app.schemas.feedback import (
    CreateFeedbackRoundRequest,
    FeedbackResults,
    FeedbackRoundDetail,
    FeedbackRoundSummary,
    QuestionnaireSummary,
    QuestionSummary,
    ResponseCredentialResponse,
    ScaleQuestionResult,
    SubmitFeedbackRequest,
    TextQuestionResult,
)

router = APIRouter(prefix="/api/v1", tags=["feedback"])


def _hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def _questions_for_questionnaire(db: Session, questionnaire_id: UUID) -> list[Question]:
    return list(
        db.scalars(
            select(Question)
            .where(Question.questionnaire_id == questionnaire_id)
            .order_by(Question.position)
        ).all()
    )


def _question_summary(question: Question) -> QuestionSummary:
    return QuestionSummary(
        id=question.id,
        key=question.key,
        prompt=question.prompt,
        kind=question.kind,
        position=question.position,
        required=question.required,
        min_score=question.min_score,
        max_score=question.max_score,
    )


def _questionnaire(db: Session, slug: str) -> Questionnaire:
    questionnaire = db.scalar(
        select(Questionnaire)
        .where(Questionnaire.slug == slug)
        .order_by(Questionnaire.version.desc())
    )
    if questionnaire is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Questionnaire not found")
    return questionnaire


def _questionnaire_slug(db: Session, questionnaire_id: UUID) -> str:
    slug = db.scalar(select(Questionnaire.slug).where(Questionnaire.id == questionnaire_id))
    if slug is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Round questionnaire is unavailable",
        )
    return slug


def _round_summary(db: Session, feedback_round: FeedbackRound) -> FeedbackRoundSummary:
    return FeedbackRoundSummary(
        id=feedback_round.id,
        group_id=feedback_round.group_id,
        subject_user_id=feedback_round.subject_user_id,
        questionnaire_slug=_questionnaire_slug(db, feedback_round.questionnaire_id),
        status=feedback_round.status,
        min_responses=feedback_round.min_responses,
        created_at=feedback_round.created_at,
        opened_at=feedback_round.opened_at,
        closed_at=feedback_round.closed_at,
    )


def _membership(db: Session, group_id: UUID, user_id: UUID) -> GroupMember | None:
    return db.scalar(
        select(GroupMember).where(
            GroupMember.group_id == group_id,
            GroupMember.user_id == user_id,
        )
    )


def _round_for_member(db: Session, round_id: UUID, user_id: UUID) -> FeedbackRound:
    feedback_round = db.scalar(select(FeedbackRound).where(FeedbackRound.id == round_id))
    if feedback_round is None or _membership(db, feedback_round.group_id, user_id) is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback round not found"
        )
    return feedback_round


def _subject_round(db: Session, round_id: UUID, user_id: UUID) -> FeedbackRound:
    feedback_round = db.scalar(
        select(FeedbackRound).where(
            FeedbackRound.id == round_id,
            FeedbackRound.subject_user_id == user_id,
        )
    )
    if feedback_round is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback round not found"
        )
    return feedback_round


def _new_response_credential(db: Session, round_id: UUID) -> tuple[str, str]:
    for _ in range(5):
        token = secrets.token_urlsafe(32)
        token_hash = _hash_token(token)
        exists = db.scalar(
            select(ResponseCredential.id).where(ResponseCredential.token_hash == token_hash)
        )
        if exists is None:
            return token, token_hash
    raise HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail="Could not allocate a response credential",
    )


@router.get("/questionnaires/{slug}", response_model=QuestionnaireSummary)
def get_questionnaire(
    slug: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> QuestionnaireSummary:
    questionnaire = _questionnaire(db, slug)
    questions = _questions_for_questionnaire(db, questionnaire.id)
    return QuestionnaireSummary(
        id=questionnaire.id,
        slug=questionnaire.slug,
        name=questionnaire.name,
        version=questionnaire.version,
        questions=[_question_summary(question) for question in questions],
    )


@router.post(
    "/groups/{group_id}/feedback-rounds",
    response_model=FeedbackRoundSummary,
    status_code=status.HTTP_201_CREATED,
)
def create_feedback_round(
    group_id: UUID,
    request: CreateFeedbackRoundRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FeedbackRoundSummary:
    if _membership(db, group_id, user.id) is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")

    questionnaire = _questionnaire(db, request.questionnaire_slug)
    feedback_round = FeedbackRound(
        group_id=group_id,
        subject_user_id=user.id,
        questionnaire_id=questionnaire.id,
        status="draft",
        min_responses=request.min_responses,
    )
    db.add(feedback_round)
    db.commit()
    db.refresh(feedback_round)
    return _round_summary(db, feedback_round)


@router.get(
    "/groups/{group_id}/feedback-rounds",
    response_model=list[FeedbackRoundSummary],
)
def list_feedback_rounds(
    group_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[FeedbackRoundSummary]:
    if _membership(db, group_id, user.id) is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")

    rounds = db.scalars(
        select(FeedbackRound)
        .where(FeedbackRound.group_id == group_id)
        .order_by(FeedbackRound.created_at.desc())
    ).all()
    return [_round_summary(db, feedback_round) for feedback_round in rounds]


@router.get("/feedback-rounds/{round_id}", response_model=FeedbackRoundDetail)
def get_feedback_round(
    round_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FeedbackRoundDetail:
    feedback_round = _round_for_member(db, round_id, user.id)
    questions = _questions_for_questionnaire(db, feedback_round.questionnaire_id)
    return FeedbackRoundDetail(
        **_round_summary(db, feedback_round).model_dump(),
        questions=[_question_summary(question) for question in questions],
    )


@router.post("/feedback-rounds/{round_id}/open", response_model=FeedbackRoundSummary)
def open_feedback_round(
    round_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FeedbackRoundSummary:
    feedback_round = _subject_round(db, round_id, user.id)
    if feedback_round.status != "draft":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Only draft feedback rounds can be opened",
        )

    eligible_count = db.scalar(
        select(func.count())
        .select_from(GroupMember)
        .where(
            GroupMember.group_id == feedback_round.group_id,
            GroupMember.user_id != feedback_round.subject_user_id,
        )
    )
    if (eligible_count or 0) < feedback_round.min_responses:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Not enough eligible group members for minimum response threshold",
        )

    feedback_round.status = "open"
    feedback_round.opened_at = datetime.now(UTC)
    db.commit()
    return _round_summary(db, feedback_round)


@router.post(
    "/feedback-rounds/{round_id}/credentials",
    response_model=ResponseCredentialResponse,
    status_code=status.HTTP_201_CREATED,
)
def claim_response_credential(
    round_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ResponseCredentialResponse:
    feedback_round = _round_for_member(db, round_id, user.id)
    if feedback_round.status != "open":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Feedback round is not open",
        )
    if feedback_round.subject_user_id == user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Round subject cannot submit feedback",
        )

    existing_claim = db.scalar(
        select(CredentialClaim.id).where(
            CredentialClaim.round_id == round_id,
            CredentialClaim.user_id == user.id,
        )
    )
    if existing_claim is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Response credential already claimed",
        )

    token, token_hash = _new_response_credential(db, round_id)
    db.add(CredentialClaim(round_id=round_id, user_id=user.id))
    db.add(ResponseCredential(round_id=round_id, token_hash=token_hash))
    db.commit()
    return ResponseCredentialResponse(response_token=token)


def _validated_answers(
    request: SubmitFeedbackRequest,
    questions: list[Question],
) -> list[tuple[Question, int | None, str | None]]:
    question_by_id = {question.id: question for question in questions}
    submitted_ids = [answer.question_id for answer in request.answers]
    if len(submitted_ids) != len(set(submitted_ids)):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT, detail="Duplicate answer"
        )

    unknown = set(submitted_ids) - set(question_by_id)
    if unknown:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="Answer contains a question outside this round",
        )

    answer_by_id = {answer.question_id: answer for answer in request.answers}
    missing_required = [
        question.id
        for question in questions
        if question.required and question.id not in answer_by_id
    ]
    if missing_required:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="All required questions must be answered",
        )

    validated: list[tuple[Question, int | None, str | None]] = []
    for question in questions:
        submission = answer_by_id.get(question.id)
        if submission is None:
            continue

        if question.kind == "scale":
            if submission.score is None or submission.text is not None:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                    detail="Scale questions require only a numeric score",
                )
            if (
                question.min_score is not None
                and submission.score < question.min_score
                or question.max_score is not None
                and submission.score > question.max_score
            ):
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                    detail="Score is outside the allowed range",
                )
            validated.append((question, submission.score, None))
            continue

        if question.kind == "text":
            if submission.score is not None:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                    detail="Text questions cannot contain a numeric score",
                )
            normalized = submission.text.strip() if submission.text is not None else ""
            if not normalized:
                if question.required:
                    raise HTTPException(
                        status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                        detail="Required text question cannot be empty",
                    )
                continue
            validated.append((question, None, normalized))
            continue

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unsupported question type",
        )

    return validated


@router.post(
    "/feedback-rounds/{round_id}/responses",
    status_code=status.HTTP_201_CREATED,
)
def submit_feedback(
    round_id: UUID,
    request: SubmitFeedbackRequest,
    response_token: Annotated[str, Header(alias="X-Response-Token", min_length=32)],
    db: Session = Depends(get_db),
) -> dict[str, str]:
    feedback_round = db.get(FeedbackRound, round_id)
    if feedback_round is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback round not found"
        )
    if feedback_round.status != "open":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Feedback round is not open",
        )

    credential = db.scalar(
        select(ResponseCredential)
        .where(
            ResponseCredential.round_id == round_id,
            ResponseCredential.token_hash == _hash_token(response_token),
        )
        .with_for_update()
    )
    if credential is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid response credential",
        )
    if credential.used_at is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Response credential already used",
        )

    questions = _questions_for_questionnaire(db, feedback_round.questionnaire_id)
    validated = _validated_answers(request, questions)

    anonymous_response = AnonymousResponse(round_id=round_id)
    db.add(anonymous_response)
    db.flush()
    db.add_all(
        Answer(
            response_id=anonymous_response.id,
            question_id=question.id,
            score=score,
            text_value=text_value,
        )
        for question, score, text_value in validated
    )
    credential.used_at = datetime.now(UTC)
    db.commit()
    return {"status": "accepted"}


@router.post("/feedback-rounds/{round_id}/close", response_model=FeedbackRoundSummary)
def close_feedback_round(
    round_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FeedbackRoundSummary:
    feedback_round = _subject_round(db, round_id, user.id)
    if feedback_round.status != "open":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Only open feedback rounds can be closed",
        )

    feedback_round.status = "closed"
    feedback_round.closed_at = datetime.now(UTC)
    db.commit()
    return _round_summary(db, feedback_round)


@router.get("/feedback-rounds/{round_id}/results", response_model=FeedbackResults)
def get_feedback_results(
    round_id: UUID,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FeedbackResults:
    feedback_round = _subject_round(db, round_id, user.id)
    if feedback_round.status != "closed":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Results are available only after the round is closed",
        )

    response_count = db.scalar(
        select(func.count())
        .select_from(AnonymousResponse)
        .where(AnonymousResponse.round_id == round_id)
    )
    if (response_count or 0) < feedback_round.min_responses:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Minimum response threshold not met",
        )

    questions = _questions_for_questionnaire(db, feedback_round.questionnaire_id)
    scale_results: list[ScaleQuestionResult] = []
    text_results: list[TextQuestionResult] = []

    for question in questions:
        if question.kind == "scale":
            scores = list(
                db.scalars(
                    select(Answer.score)
                    .join(AnonymousResponse, AnonymousResponse.id == Answer.response_id)
                    .where(
                        AnonymousResponse.round_id == round_id,
                        Answer.question_id == question.id,
                    )
                ).all()
            )
            numeric_scores = [score for score in scores if score is not None]
            average = round(sum(numeric_scores) / len(numeric_scores), 2)
            distribution = {
                str(score): numeric_scores.count(score)
                for score in range(question.min_score or 1, (question.max_score or 5) + 1)
            }
            scale_results.append(
                ScaleQuestionResult(
                    question_id=question.id,
                    key=question.key,
                    prompt=question.prompt,
                    average=average,
                    distribution=distribution,
                )
            )
            continue

        comments = list(
            db.scalars(
                select(Answer.text_value)
                .join(AnonymousResponse, AnonymousResponse.id == Answer.response_id)
                .where(
                    AnonymousResponse.round_id == round_id,
                    Answer.question_id == question.id,
                    Answer.text_value.is_not(None),
                )
                .order_by(Answer.text_value)
            ).all()
        )
        text_results.append(
            TextQuestionResult(
                question_id=question.id,
                key=question.key,
                prompt=question.prompt,
                comments=[comment for comment in comments if comment is not None],
            )
        )

    return FeedbackResults(
        round_id=round_id,
        response_count=response_count or 0,
        scale_results=scale_results,
        text_results=text_results,
    )
