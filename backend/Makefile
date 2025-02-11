# Load environment variables from .env file if available (cross-platform)
ifneq (,$(wildcard .env))
    include .env
    export $(shell awk -F= '!/^#/ {print $$1}' .env)
endif

.PHONY: buildx-dev run-dev clean-dev buildx-push run-tests

# ✅ Multi-arch BuildX build (local)
buildx-dev:
	docker buildx create --use
	docker buildx build --load --platform linux/amd64,linux/arm64 \
		-t ${DOCKER_HUB_USER:-proppele1}/soen-390-backend:dev-local .

# ✅ Start the local container
run-dev:
	DOCKER_HUB_USER=${DOCKER_HUB_USER:-proppele1} \
	DOCKER_TAG=$(shell git rev-parse --abbrev-ref HEAD) \
	docker compose up -d

# ✅ Stop and clean up
clean-dev:
	docker compose down
	docker image rm ${DOCKER_HUB_USER:-proppele1}/soen-390-backend:dev-local

# ✅ Build and push branch-specific image to Docker Hub
buildx-push:
	@echo "Using Docker Hub user: ${DOCKER_HUB_USER:-proppele1}"
	@$(if $(DOCKER_HUB_USER),,$(error ❌ DOCKER_HUB_USER is not set! Run `export DOCKER_HUB_USER=<your-username>` before running this command.))
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t ${DOCKER_HUB_USER}/soen-390-backend:$(shell git rev-parse --abbrev-ref HEAD) \
		--push .

# ✅ Run tests
run-tests:
	DOCKER_HUB_USER=${DOCKER_HUB_USER:-proppele1} \
	DOCKER_TAG=$(shell git rev-parse --abbrev-ref HEAD) \
	docker compose -f docker-compose.test.yml up --abort-on-container-exit
