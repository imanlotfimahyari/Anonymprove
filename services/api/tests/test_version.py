import tomllib
from pathlib import Path

from app.main import app


def test_fastapi_version_matches_pyproject() -> None:
    pyproject_path = Path(__file__).parents[1] / "pyproject.toml"
    pyproject = tomllib.loads(pyproject_path.read_text(encoding="utf-8"))

    assert app.version == pyproject["project"]["version"]
