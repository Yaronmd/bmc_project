# Jenkins A → B Trigger Project

This project sets up **two Jenkins servers** (`jenkins-a` and `jenkins-b`) using Docker Compose.
When a job on `jenkins-a` is triggered, it checks a condition and, if met, triggers a job on `jenkins-b` using the Jenkins REST API, including authentication and CSRF crumb handling.


---

## Project Structure

```
.
├── docker-compose.yml              # Defines both Jenkins servers
├── jenkins-a/
│   ├── Dockerfile                  # Jenkins A Dockerfile
│   └── scripts/                   # Shell script to check condition and trigger Jenkins B
├── jenkins-b/
│   ├── Dockerfile                  # Jenkins B Dockerfile
│   └── scripts/                   # Contains hello.py (prints "Hello BMC")
├── README.md                       # You're here
└── start_jenkins.sh                # Script to start and initialize both Jenkins containers
```

---

## How it works

1. `job-a` on **Jenkins A** runs a shell script: `validate_ls.sh`
2. The script counts the number of files in `/scripts`
3. If more than 3 files exist, it:

   * Sends an authenticated API request to trigger `job-b`
4. `job-b` runs a Python script that writes `Hello BMC` to a file
5. Console log from `job-b` is printed inside `job-a`

---

## Prerequisites

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/)

---

## Getting Started

```bash
# Clone the repo
cd bmc_project

# Start both Jenkins instances and reset Jenkins A volume
./start_jenkins.sh
```

### First-time Setup

After containers are up:

1. Open Jenkins A: [http://localhost:8080](http://localhost:8080)
2. Open Jenkins B: [http://localhost:8081](http://localhost:8081)
3. Retrieve admin passwords:

```bash
docker exec jenkins-a cat /var/jenkins_home/secrets/initialAdminPassword
docker exec jenkins-b cat /var/jenkins_home/secrets/initialAdminPassword
```

4. Finish setup via UI (disable plugin suggestions if desired)

5. **Create a job in Jenkins A named `job-a`**

6. **Configure `job-a` like this**:

   * Type: **Freestyle project**
   * Build Step: `Execute shell`
   * Command:

     ```bash
     /scripts/validate_ls.sh
     ```
   * Ensure the job runs as `admin` and environment variables are passed from `.env`

7. **Create a job in Jenkins B named `job-b`**

8. Add token-based triggering in `job-b`:

   * Go to **job-b → Configure**
   * Enable  **"Trigger builds remotely"**
   * Set token: `mytoken123` (or any value)

---

## How to Get Jenkins API Token

1. Go to **[http://localhost:8081](http://localhost:8081)** (Jenkins B)
2. Click on your username (`admin`)
3. Click **"Configure"** (left menu)
4. Scroll to **"API Token"** section
5. Click **"Add new token"**
6. Name it `bmc_token`, then copy the generated token
7. Save it in `.env` file in root project folder:

```env
JENKINS_B_URL=http://jenkins-b:8080
TARGET_JOB_NAME=job-b
JENKINS_USER=admin
JENKINS_API_TOKEN=your_token_here
```

> ⚠️ Make sure `docker-compose.yml` includes:

```yaml
env_file:
  - .env
```

Then restart Jenkins A:

```bash
docker compose restart jenkins-a
```



## 🧼 Clean Up

```bash
docker compose down -v
```

---

## 👨‍💻 Developed by

Yaron Mordechai
