.PHONY: buildx-dev run-dev clean-dev buildx-push run-tests

# ✅ Multi-arch BuildX build (local)
buildx-dev:
	docker buildx create --use
	docker buildx build --load --platform linux/amd64,linux/arm64 \
		-t $(strip $(DOCKER_HUB_USER))/soen-390-backend:dev-local .

# ✅ Start the local container
run-dev:
	@echo "Using Docker Hub user: $(strip $(DOCKER_HUB_USER))"
ifeq ($(OS),Windows_NT)
	cmd /c "set DOCKER_HUB_USER=$(strip $(DOCKER_HUB_USER))&& set DOCKER_TAG=$(shell git rev-parse --abbrev-ref HEAD)&& docker compose up -d"
else
	export DOCKER_HUB_USER=$(strip $(DOCKER_HUB_USER)); \
	export DOCKER_TAG=$(shell git rev-parse --abbrev-ref HEAD); \
	docker compose up -d
endif

# ✅ Stop and clean up
clean-dev:
	docker compose down
	docker image rm $(strip $(DOCKER_HUB_USER))/soen-390-backend:dev-local

# ✅ Build and push branch-specific image to Docker Hub
buildx-push:
	@echo "Using Docker Hub user: $(strip $(DOCKER_HUB_USER))"
ifeq ($(OS),Windows_NT)
	cmd /c "set DOCKER_HUB_USER=$(strip $(DOCKER_HUB_USER))&& docker buildx build --platform linux/amd64,linux/arm64 -t $(strip $(DOCKER_HUB_USER))/soen-390-backend:$(shell git rev-parse --abbrev-ref HEAD) --push ."
else
	export DOCKER_HUB_USER=$(strip $(DOCKER_HUB_USER)); \
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(strip $(DOCKER_HUB_USER))/soen-390-backend:$(shell git rev-parse --abbrev-ref HEAD) \
		--push .
endif

# ✅ Run tests (updated)
run-tests:
ifeq ($(OS),Windows_NT)
	cmd /c "set DOCKER_HUB_USER=$(strip $(DOCKER_HUB_USER))&& set DOCKER_TAG=$(shell git rev-parse --abbrev-ref HEAD)&& docker compose -f ../docker-compose.test.yml up --abort-on-container-exit"
else
	export DOCKER_HUB_USER=$(strip $(DOCKER_HUB_USER)); \
	export DOCKER_TAG=$(shell git rev-parse --abbrev-ref HEAD); \
	docker compose -f ../docker-compose.test.yml up --abort-on-container-exit
endif
