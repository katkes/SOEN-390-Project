# 🚀 Local Development Guide with Docker & Makefile

## **🌍 Overview**

This guide will help you develop, run, and test your Django application locally using **Docker, Docker Compose**, and the **Makefile** for automation. THIS ONLY CONSIDERS THE Backend directory.

## **🔹 Prerequisites**

Before running your application, ensure you have:

- ✅ **Docker installed** ([Download](https://www.docker.com/get-started))
- ✅ **Docker Compose installed** (included with Docker Desktop)
- ✅ **Make installed** (for automation via `Makefile`)
- ✅ **.env file with DOCKER_HUB_USER=youdockerusername**

---

## **📌 Step 1: Build Your Local Development Image**

First, build your local image using:

```sh
make buildx-dev
```

### **What happens?**

- **Uses BuildX** to create a **multi-architecture** build (`amd64` & `arm64`).
- **Loads the image locally** without pushing it to Docker Hub.
- Creates a **tagged image**:
  ```sh
  ${DOCKER_HUB_USER:-proppele1}/soen-390-backend:dev-local
  ```

---

## **📌 Step 2: Start the Local Container**

Run your app inside a container:

```sh
make run-dev
```

### **What happens?**

- **Automatically sets `DOCKER_HUB_USER`** to your current username (or defaults to `proppele1`).
- **Automatically sets `DOCKER_TAG`** to your current branch.
- Runs `docker compose up -d`, starting your Django app.
- **Mounts your local files** (`- .:/app`) so changes reflect immediately.

✅ **Now your app is running!** Open your browser and go to:
📌 [http://localhost:8080](http://localhost:8080)

---

## **📌 Step 3: Make Code Changes & See Live Updates**

Since your `docker-compose.override.yml` **mounts local files (`- .:/app`)**, any code changes in your project will reflect inside the running container.

### **Example:**

1. **Modify a Django view (`views.py`)**:

   ```python
   from django.http import JsonResponse

   def hello(request):
       return JsonResponse({"message": "Hello, world!"})
   ```

2. **Update `urls.py` to include the new view:**

   ```python
   from django.urls import path
   from .views import hello

   urlpatterns = [
       path('hello/', hello),
   ]
   ```

3. **Save your files.**
4. **Your changes should be live** (No need to rebuild your container).

📌 Now visit: [http://localhost:8080/hello/](http://localhost:8080/hello/)
✅ **You should see:**

```json
{ "message": "Hello, world!" }
```

---

## **📌 Step 4: Running Tests Locally**

To run tests in the container, use:

```sh
make run-tests
```

### **What happens?**

- **Sets `DOCKER_HUB_USER` dynamically** (or defaults to `proppele1`).
- **Sets `DOCKER_TAG` dynamically** to your branch.
- Uses `docker-compose.test.yml` to run tests in an **isolated environment**.
- Stops automatically when tests finish.

---

## **📌 Step 5: Stopping & Cleaning Up**

When you're done, stop and remove your local containers:

```sh
make clean-dev
```

### **What happens?**

- Stops the running containers (`docker compose down`).
- Removes the developer-specific Docker image: `${DOCKER_HUB_USER:-proppele1}/soen-390-backend:dev-local`.

---

## **📌 Step 6: Building & Pushing Your Branch Image**

If you want to **push a branch-specific image to Docker Hub**, run:

```sh
make buildx-push
```

### **What happens?**

- **Uses `DOCKER_HUB_USER` dynamically** (or defaults to `proppele1`).
- **Uses `git rev-parse --abbrev-ref HEAD`** to get your current branch name.
- Builds a multi-arch Docker image.
- Tags it as:
  ```sh
  ${DOCKER_HUB_USER}/soen-390-backend:<branch-name>
  ```
- Pushes it to Docker Hub.

---

## **📝 Summary of Commands**

| Action                 | Command            | Description                                             |
| ---------------------- | ------------------ | ------------------------------------------------------- |
| **Build Local Image**  | `make buildx-dev`  | Creates `${DOCKER_HUB_USER}/soen-390-backend:dev-local` |
| **Run Locally**        | `make run-dev`     | Starts Django in a container with live reload           |
| **Run Tests**          | `make run-tests`   | Runs Django tests inside a container                    |
| **Stop & Cleanup**     | `make clean-dev`   | Stops and removes containers                            |
| **Build & Push Image** | `make buildx-push` | Pushes branch-based Docker image                        |

---

## **🚀 Final Thoughts**

✅ **With this setup, you can:**

- Develop locally with **instant updates**.
- Run tests in a **consistent, isolated environment**.
- Push **branch-specific** images to Docker Hub.
- Use **Docker for everything**, reducing “works on my machine” issues.

Let me know if you need further clarifications! 🚀
