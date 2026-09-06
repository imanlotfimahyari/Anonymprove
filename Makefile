.PHONY: setup-api lint-api format-api test-api audit-api docker-build client-get client-check check

setup-api:
	python -m pip install -e "services/api[dev]"

lint-api:
	ruff check services/api
	ruff format --check services/api

format-api:
	ruff check --fix services/api
	ruff format services/api

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

check: lint-api test-api audit-api client-check docker-build
