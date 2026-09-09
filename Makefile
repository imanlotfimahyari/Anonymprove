.PHONY: setup-api lint-api format-api migrate-api test-api audit-api docker-build client-get client-check client-build-android check

setup-api:
	python -m pip install -e "services/api[dev]"

lint-api:
	ruff check services/api
	ruff format --check services/api

format-api:
	ruff check --fix services/api
	ruff format services/api

migrate-api:
	alembic -c services/api/alembic.ini upgrade head

test-api:
	JWT_SECRET=local-test-secret-not-for-production-0123456789 pytest services/api

audit-api:
	python -m pip_audit

docker-build:
	docker build -t privacy-feedback-api:dev services/api

client-get:
	cd apps/client && flutter pub get

client-check: client-get
	cd apps/client && flutter analyze
	cd apps/client && flutter test --coverage

client-build-android: client-get
	cd apps/client && flutter build apk --debug

check: lint-api test-api audit-api client-check client-build-android docker-build
