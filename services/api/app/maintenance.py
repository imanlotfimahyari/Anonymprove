from datetime import UTC, datetime, timedelta

from app.core.config import get_settings
from app.core.retention import purge_closed_round_credential_metadata
from app.db.session import get_session_factory


def main() -> None:
    settings = get_settings()
    cutoff = datetime.now(UTC) - timedelta(days=settings.credential_metadata_retention_days)

    with get_session_factory()() as db:
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
