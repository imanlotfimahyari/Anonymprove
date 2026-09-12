import argparse
from datetime import UTC, datetime, timedelta

from app.core.config import get_settings
from app.core.retention import (
    count_closed_round_credential_metadata,
    purge_closed_round_credential_metadata,
)
from app.db.session import get_session_factory


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Anonymprove maintenance tasks")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Report eligible credential metadata without deleting it.",
    )
    return parser


def main() -> None:
    args = _parser().parse_args()
    settings = get_settings()
    cutoff = datetime.now(UTC) - timedelta(days=settings.credential_metadata_retention_days)

    with get_session_factory()() as db:
        if args.dry_run:
            counts = count_closed_round_credential_metadata(
                db,
                older_than=cutoff,
            )
            print(
                "credential metadata purge dry-run: "
                f"claims={counts.credential_claims} "
                f"credentials={counts.response_credentials}"
            )
            return

        result = purge_closed_round_credential_metadata(
            db,
            older_than=cutoff,
        )
        db.commit()

    print(
        "credential metadata purge complete: "
        f"claims={result.credential_claims_deleted} "
        f"credentials={result.response_credentials_deleted}"
    )


if __name__ == "__main__":
    main()
