.PHONY: buildx-dev run-dev clean-dev buildx-push

# ✅ Multi-arch BuildX build (local)
buildx-dev:
	docker buildx create --use
	docker buildx build --load --platform linux/amd64,linux/arm64 -t soen-390-backend:dev-local .

# ✅ Start the local container
run-dev:
	docker compose up -d

# ✅ Stop and clean up
clean-dev:
	docker compose down
	docker image rm soen-390-backend:dev-local

# ✅ Build and push branch-specific image to Docker Hub
buildx-push:
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t your-dockerhub-user/soen-390-backend:$(shell git rev-parse --abbrev-ref HEAD) \
		--push .
