from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.feedback import Question, Questionnaire

CORE_QUESTIONNAIRE_ID = UUID("d81af293-59b8-461a-8b72-769909ba5a2e")
CORE_QUESTIONNAIRE_SLUG = "core-feedback-v1"
CORE_QUESTIONS = (
    (
        UUID("424f3385-8c31-46f8-806d-306e45d3aac2"),
        "communication",
        "Communicates clearly and honestly.",
        "scale",
        1,
        True,
        1,
        5,
    ),
    (
        UUID("b7e9cd8d-f5bf-416d-9744-9b9c9e27fefb"),
        "listening",
        "Listens carefully and makes others feel heard.",
        "scale",
        2,
        True,
        1,
        5,
    ),
    (
        UUID("73c96b3f-11ae-48e9-b59e-34f6de68e896"),
        "reliability",
        "Follows through on commitments and can be relied on.",
        "scale",
        3,
        True,
        1,
        5,
    ),
    (
        UUID("20a943bf-b4b1-4f77-b91a-7741df150277"),
        "empathy",
        "Shows empathy and considers other people's feelings.",
        "scale",
        4,
        True,
        1,
        5,
    ),
    (
        UUID("5c942383-d284-44a7-bc86-98d3415812dd"),
        "boundaries",
        "Respects personal boundaries and differences.",
        "scale",
        5,
        True,
        1,
        5,
    ),
    (
        UUID("e6226044-371a-447c-acdc-8cde5a7d17bd"),
        "conflict",
        "Handles disagreement without humiliation, threats, or unnecessary escalation.",
        "scale",
        6,
        True,
        1,
        5,
    ),
    (
        UUID("1ae392f1-33a9-47d1-848d-4a3f77c8af5c"),
        "supportiveness",
        "Is supportive without creating pressure, exclusion, or unhealthy dependence.",
        "scale",
        7,
        True,
        1,
        5,
    ),
    (
        UUID("80669c7b-8cbf-440c-8abf-ea613e23676b"),
        "improvement",
        "What is one thing I could do differently to improve our interactions? "
        "Avoid names or identifying details.",
        "text",
        8,
        False,
        None,
        None,
    ),
)
GROUP_HEALTH_QUESTIONNAIRE_ID = UUID("f0c4aac5-9c32-4331-a701-606d3fe94b6d")
GROUP_HEALTH_QUESTIONNAIRE_SLUG = "core-group-health-v1"

GROUP_HEALTH_QUESTIONS = (
    (
        UUID("510b27e9-8ff8-48ec-81ad-abc60374e026"),
        "communication",
        "People in this group communicate important things clearly and honestly.",
        "scale",
        1,
        True,
        1,
        5,
    ),
    (
        UUID("b3d75e30-e172-4d30-bcee-737ac793722d"),
        "listening",
        "People listen to each other and different views can be expressed.",
        "scale",
        2,
        True,
        1,
        5,
    ),
    (
        UUID("4910f797-7bd8-4b81-b242-0a336b38606b"),
        "safety",
        "People can disagree without ridicule, threats, or retaliation.",
        "scale",
        3,
        True,
        1,
        5,
    ),
    (
        UUID("a2d8d3c2-baf4-4096-bdf6-1c1166f9efb9"),
        "reliability",
        "People generally follow through on commitments to the group.",
        "scale",
        4,
        True,
        1,
        5,
    ),
    (
        UUID("25c69b61-d4e8-45a7-b62f-d942c6b76043"),
        "support",
        "People help each other when support is reasonably needed.",
        "scale",
        5,
        True,
        1,
        5,
    ),
    (
        UUID("d5124215-8dc3-44fd-a175-aab5868495ca"),
        "conflict",
        "Problems and disagreements are handled constructively.",
        "scale",
        6,
        True,
        1,
        5,
    ),
    (
        UUID("5fa31a08-46e6-4dd1-a55f-23ab38d88f16"),
        "boundaries",
        "Personal boundaries and differences are respected.",
        "scale",
        7,
        True,
        1,
        5,
    ),
    (
        UUID("1780f421-e610-4eb9-aada-62a822fe6b9c"),
        "improvement",
        "What is one thing this group could improve? Avoid names or identifying details.",
        "text",
        8,
        False,
        None,
        None,
    ),
)


def seed_core_questionnaire(db: Session) -> None:
    exists = db.scalar(
        select(Questionnaire.id).where(
            Questionnaire.slug == CORE_QUESTIONNAIRE_SLUG,
            Questionnaire.version == 1,
        )
    )
    if exists is not None:
        return

    db.add(
        Questionnaire(
            id=CORE_QUESTIONNAIRE_ID,
            group_id=None,
            created_by_user_id=None,
            slug=CORE_QUESTIONNAIRE_SLUG,
            name="Core constructive feedback",
            description="Built-in constructive self-improvement feedback questionnaire.",
            version=1,
            status="published",
        )
    )

    db.flush()

    db.add_all(
        Question(
            id=question_id,
            questionnaire_id=CORE_QUESTIONNAIRE_ID,
            key=key,
            prompt=prompt,
            kind=kind,
            position=position,
            required=required,
            min_score=min_score,
            max_score=max_score,
        )
        for (
            question_id,
            key,
            prompt,
            kind,
            position,
            required,
            min_score,
            max_score,
        ) in CORE_QUESTIONS
    )


def seed_core_group_health_questionnaire(db: Session) -> None:
    exists = db.scalar(
        select(Questionnaire.id).where(
            Questionnaire.slug == GROUP_HEALTH_QUESTIONNAIRE_SLUG,
            Questionnaire.version == 1,
        )
    )
    if exists is not None:
        return

    db.add(
        Questionnaire(
            id=GROUP_HEALTH_QUESTIONNAIRE_ID,
            group_id=None,
            created_by_user_id=None,
            slug=GROUP_HEALTH_QUESTIONNAIRE_SLUG,
            name="Core group health",
            description=("Built-in anonymous questionnaire for assessing group dynamics."),
            version=1,
            status="published",
        )
    )

    db.flush()

    db.add_all(
        Question(
            id=question_id,
            questionnaire_id=GROUP_HEALTH_QUESTIONNAIRE_ID,
            key=key,
            prompt=prompt,
            kind=kind,
            position=position,
            required=required,
            min_score=min_score,
            max_score=max_score,
        )
        for (
            question_id,
            key,
            prompt,
            kind,
            position,
            required,
            min_score,
            max_score,
        ) in GROUP_HEALTH_QUESTIONS
    )
