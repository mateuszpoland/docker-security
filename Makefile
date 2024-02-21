HADOLINT_IGNORES = --ignore DL3018
CONTAINER_NAME = hugo-website

default: lint run

lint:
	@echo "Linting Dockerfile with hadolint..."
	@docker run --rm -i hadolint/hadolint hadolint $(HADOLINT_IGNORES) - < Dockerfile
	@echo "Linting completed. No violations detected."

build: lint
	@echo "Building Hugo Builder container..."
	@docker build -t mateuszpoland/hugo-builder .
	@echo "Hugo Builder container built!"

#ensure the build is run first
run: build
	@echo "Running Hugo server in the container..."
	@docker run -d -p 1313:1313 -v $(shell pwd)/orgdocs:/src/:rw --name $(CONTAINER_NAME) mateuszpoland/hugo-builder /bin/sh -c "hugo && hugo server -w --bind=0.0.0.0"
	@echo "Hugo server is running at http://localhost:1313"
	@docker inspect --format='{{json .State.Health}}' $(CONTAINER_NAME)

.PHONY: build run
