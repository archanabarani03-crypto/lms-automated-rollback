# Jenkins LMS Automated Rollback Mechanism

## 1. Problem Statement
Jenkins can complete an LMS deployment even when the newly deployed application returns errors. The pipeline must validate application health and restore the previous working version when the new version fails.

## 2. Objective
Implement a Docker-based deployment pipeline that builds versioned application images, deploys a new version, checks its health, and automatically restores the previous known-good version on failure.

## 3. Architecture
Developer → GitHub → Jenkins → Docker Image Build → Deployment → HTTP Health Check → Success or Automatic Rollback → Recovery Verification.

## 4. Technology Stack
- AWS EC2 with Ubuntu
- Jenkins Pipeline
- Git and GitHub
- Docker Engine
- Python HTTP application for failure simulation
- Bash health-check and rollback scripts

## 5. Implementation
1. Create and configure the Ubuntu EC2 instance.
2. Install Java, Git, Docker and Jenkins.
3. Create the application and Dockerfile.
4. Implement the health-check script.
5. Implement deployment and rollback logic.
6. Configure the Jenkinsfile.
7. Push the project to GitHub.
8. Configure Jenkins to retrieve the Jenkinsfile from source control.
9. Run a successful deployment.
10. Trigger a controlled health-check failure and verify recovery.

## 6. Rollback Logic
The deployment script reads the previously successful image tag, starts the new version and performs repeated health checks. If the new version is unhealthy, the script removes it, starts the previous image and validates recovery.

## 7. Expected Results
- Healthy deployment: Jenkins reports SUCCESS.
- Unhealthy deployment with successful rollback: Jenkins reports FAILURE while the previous application version becomes healthy.
- Failed rollback: the pipeline reports a critical recovery failure requiring investigation.

## 8. Root-Cause Analysis
The scenario results from insufficient post-deployment validation. A successful build or container start does not prove that the application or its dependencies are healthy.

## 9. Troubleshooting
Inspect Jenkins console output, Docker container status, application logs, health endpoint responses, port conflicts, stored image tags and Docker service logs.

## 10. Prevention
Use immutable versioned images, pre-deployment tests, application-specific readiness checks, retained release artifacts, backward-compatible database migrations, alerts and regular rollback exercises.

## 11. Limitations
This project uses a sample HTTP application. A production Open edX/Tutor deployment requires a Tutor-compatible release and recovery procedure, dependency validation and public LMS endpoint checks. Database rollback is not handled by this sample.

## 12. Conclusion
The mechanism provides automated recovery from application-level deployment failures and ensures that a release is not marked successful solely because the deployment command completed.
