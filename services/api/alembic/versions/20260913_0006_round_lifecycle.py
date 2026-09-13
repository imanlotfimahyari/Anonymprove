"""Add feedback-round lifecycle states and deadline.

Revision ID: 20260913_0006
Revises: 20260912_0005
Create Date: 2026-09-13
"""

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "20260913_0006"
down_revision: str | None = "20260912_0005"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "feedback_rounds",
        sa.Column(
            "response_deadline_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
    )

    op.drop_constraint(
        "ck_feedback_rounds_status",
        "feedback_rounds",
        type_="check",
    )

    op.create_check_constraint(
        "ck_feedback_rounds_status",
        "feedback_rounds",
        "status IN ('draft', 'open', 'closed', 'expired', 'closed_no_results')",
    )


def downgrade() -> None:
    rounds = sa.table(
        "feedback_rounds",
        sa.column("status", sa.String(length=16)),
    )

    op.drop_constraint(
        "ck_feedback_rounds_status",
        "feedback_rounds",
        type_="check",
    )

    connection = op.get_bind()

    connection.execute(rounds.update().where(rounds.c.status == "expired").values(status="open"))

    connection.execute(
        rounds.update().where(rounds.c.status == "closed_no_results").values(status="closed")
    )

    op.create_check_constraint(
        "ck_feedback_rounds_status",
        "feedback_rounds",
        "status IN ('draft', 'open', 'closed')",
    )

    op.drop_column(
        "feedback_rounds",
        "response_deadline_at",
    )
