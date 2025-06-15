## Jenkins A → Jenkins B Pipeline

This project demonstrates how **Jenkins A** triggers a job on **Jenkins B** using a secure setup with credentials and API tokens. Both Jenkins instances are connected to GitHub for Pipeline as Code using Jenkinsfiles stored in the repository.
---

## How it works

### Jenkins A

- Runs a job that executes `ls` on a target directory.
- Counts the total number of "word-like" parts in file names (e.g., words separated by `-` or `_`).
- If the total count is greater than `3`, Jenkins A securely triggers a job on Jenkins B using API tokens and credentials.

### Jenkins B

- The triggered job executes a Python program (`hello.py`) that writes a file `/tmp/hello_bmc.txt` containing:
  ```
  Hello BMC
  ```
- A verification script (`verify_hello.sh`) ensures the file was created and contains the expected content.

---

## Running Tests Before Triggering Jenkins B

Before the pipeline triggers the Jenkins B job, it runs automated tests using Docker containers.

### How it works
- The pipeline executes `/shared-scripts/run_tests.sh`.
- This script builds and runs:
  - A base Docker image (`test-base`)
  - A test container that verifies file listing (`test-ls`)
  - A test container that runs Python validation (`test-python-file`)
- If any test fails, the pipeline stops and Jenkins B is **not triggered**.

### Running tests manually (optional)
You can also run the tests manually:
```bash
docker exec jenkins-a /shared-scripts/run_tests.sh
```

---

## Project Structure

```
.
├── config                    # Configuration files
│   └── requirements.txt       # Python dependencies for tests
├── docker                     # Docker-related files for builds and tests
│   ├── Dockerfile.base         # Base image shared by other Dockerfiles
│   ├── Dockerfile.test_ls      # Dockerfile for testing validate_ls.sh
│   └── Dockerfile.test_python  # Dockerfile for testing Python scripts
├── docker-compose.yml          # Docker Compose setup for Jenkins services
├── jenkins-a                   # Jenkins A related setup
│   ├── Dockerfile              # Dockerfile for Jenkins A
│   ├── Jenkinsfile             # Jenkins pipeline file for Jenkins A
│   ├── scripts                 # Scripts used by Jenkins A
│   │   ├── data                # Data files used by validation script
│   │   │   └── example_to_trigger_test_b.txt # Example file to trigger Jenkins B
│   │   ├── monitor_jenkins_b.sh # Monitors triggered Jenkins B job
│   │   ├── trigger_jenkins_b.sh # Triggers Jenkins B job
│   │   └── validate_ls.sh       # Script that validates conditions and triggers Jenkins B
│   └── tests                   # Tests for Jenkins A logic
│       └── test_validate_ls.py  # Test for validate_ls.sh functionality
├── jenkins-b                   # Jenkins B related setup
│   ├── Dockerfile              # Dockerfile for Jenkins B
│   ├── Jenkinsfile             # Jenkins pipeline file for Jenkins B
│   ├── scripts                 # Scripts used by Jenkins B
│   │   └── hello.py             # Example Python script run by Jenkins B
|   |   └── validate_hello_file.sh  # Script that verifies the Hello BMC file was created 
│   └── tests                   # Tests for Jenkins B logic
│       └── test_hello_script.py # Test for hello.py script
├── README.md                   # Project documentation
├── scripts                     # Helper scripts for managing the project
│   ├── run_tests.sh             # Shell script to build & run tests via Docker
│   └── start_jenkins.sh         # Shell script to start Jenkins instances (if exists)
```

---

## Security & Configuration

- **Jenkins A** uses a **username + API token**, stored securely in Jenkins credentials, to authenticate and trigger Jenkins B.
- **Jenkins B** is configured to allow **remote triggers** using tokens (e.g. `mytoken123`).
- All sensitive values (such as API tokens, Jenkins B URL) are managed using the **Jenkins credentials manager** — no hardcoded secrets in the code.

---

## Setup Instructions

### Jenkins B - Create API Token for remote build

1. Go to **Jenkins B** → `job-b` → **Configure** → Enable\
   → **Trigger builds remotely (e.g., from scripts)**\
   → Set **Authentication Token** → `mytoken123`

2. The URL to trigger the build:

   ```
   http://<JENKINS_B_URL>/job/job-b/build?token=mytoken123
   ```

   or if parameters:

   ```
   http://<JENKINS_B_URL>/job/job-b/buildWithParameters?token=mytoken123
   ```

   *You can also append **`&cause=Triggered+by+Jenkins+A`** to set a build cause.*

---

### Jenkins A - Add required credentials

Go to **Jenkins A** → **Manage Jenkins** → **Credentials** → **(global)** → **Add Credentials**:

| Type                | ID                       | Value                                                          |
| ------------------- | ------------------------ | -------------------------------------------------------------- |
| Username + Password | `jenkins_api_token_cred` | **Username:** `admin` / **Password:** your Jenkins B API token |
| Secret text         | `JENKINS_B_URL`          | `http://jenkins-b:8080`                                        |

These credentials will be referenced in the Jenkinsfile to securely trigger Jenkins B.

---

## How to run

```bash
./scripts/start_jenkins.sh
```

This will start Jenkins A and B via Docker Compose.
To see the initial admin password for both Jenkins instances:

```bash
echo "Jenkins A password:"
docker exec jenkins-a cat /var/jenkins_home/secrets/initialAdminPassword || echo "Jenkins A not ready"

echo "Jenkins B password:"
docker exec jenkins-b cat /var/jenkins_home/secrets/initialAdminPassword || echo "Jenkins B not ready"
```

```bash
./scripts/run_tests.sh
```

This will build and run tests in Docker for the project.

---

## Notes

- Make sure Docker and Docker Compose are installed.
- Everything comes from Jenkins credentials.
- Adjust ports and URLs in `docker-compose.yml` if needed.

