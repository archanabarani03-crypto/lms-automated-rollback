
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 15, unit: 'MINUTES')
    }

    parameters {
        booleanParam(
            name: 'SIMULATE_FAILURE',
            defaultValue: false,
            description: 'Force the new version health check to fail to test rollback'
        )
    }

    environment {
        IMAGE_NAME = 'lms-rollback-demo'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    set -eu
                    docker build \
                      -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker image inspect \
                      ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy and Validate') {
            steps {
                sh '''
                    set -eu
                    bash scripts/deploy.sh \
                      "${IMAGE_NAME}:${BUILD_NUMBER}" \
                      "${SIMULATE_FAILURE}"
                '''
            }
        }

        stage('Verify Application') {
            steps {
                sh '''
                    set -eu
                    bash scripts/health-check.sh \
                      http://127.0.0.1:8081/health 3 2
                    curl --fail --silent \
                      http://127.0.0.1:8081/
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment completed and application is healthy.'
        }

        failure {
            echo 'Deployment failed or rollback was triggered. Inspect the console log.'
        }

        always {
            sh '''
                docker ps -a --filter name=lms-app || true
            '''
        }
    }
}
