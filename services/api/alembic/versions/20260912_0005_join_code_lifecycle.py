"""Add join-code lifecycle support.

Revision ID: 20260912_0005
Revises: 20260910_0004
Create Date: 2026-09-12
"""

import hashlib
from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "20260912_0005"
down_revision: str | None = "20260910_0004"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.alter_column(
        "groups",
        "join_code_hash",
        existing_type=sa.String(length=64),
        nullable=True,
    )


def downgrade() -> None:
    groups = sa.table(
        "groups",
        sa.column("id", sa.Uuid()),
        sa.column("join_code_hash", sa.String(length=64)),
    )

    connection = op.get_bind()
    revoked_group_ids = connection.execute(
        sa.select(groups.c.id).where(groups.c.join_code_hash.is_(None))
    ).scalars()

    for group_id in revoked_group_ids:
        replacement = hashlib.sha256(f"{group_id}:revoked-downgrade".encode()).hexdigest()
        connection.execute(
            groups.update().where(groups.c.id == group_id).values(join_code_hash=replacement)
        )

    op.alter_column(
        "groups",
        "join_code_hash",
        existing_type=sa.String(length=64),
        nullable=False,
    )
