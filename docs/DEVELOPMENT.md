# Development Setup

## Prerequisites

- Install Docker with BuildX support
- Install `docker-compose`
- Clone the repo

## Build and Run Locally

1. **Build the multi-arch image**

   ```sh
   make buildx-dev

   ```

2. **Run the container with local changes**

   ```sh
   make run-dev

   ```

3. **Run the container with local changes**
   ```sh
   make clean-dev
   ```

## Build and Run Locally

1. **Ensure your branch is up to date**
   '''sh
   git pull origin main
   '''

2. **Build and push to docker hub**
   '''sh
   make buildx-push
   '''

3. **Your branch's image will be available at:**
   '''sh
   docker pull proppele1/soen-390-backend:your-branch-name
   '''
