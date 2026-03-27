pipeline {
    agent any

    environment {
        // Docker Hub image coordinates
        DOCKER_IMAGE = 'berkberaozer/pipelined-clinic'
        DOCKER_TAG   = "${env.BUILD_NUMBER}"
        // Deployment target
        DEPLOY_HOST  = '192.168.56.90'
        DEPLOY_USER  = 'deployer'
    }

    tools {
        maven 'Maven'   // Name must match Manage Jenkins → Tools → Maven
        jdk   'JDK21'   // Name must match Manage Jenkins → Tools → JDK
    }

    stages {

        stage('Checkout') {
            steps {
                // Pull source code from Git
                git branch: 'main',
                    url: 'https://github.com/berkberaozer/pipelined-clinic.git'
            }
        }

        stage('Compile & Test') {
            steps {
                // Compile the Java source code and run unit tests
                sh 'mvn clean package -DskipTests=false'
            }
            post {
                always {
                    // Archive test results even if the build fails
                    junit allowEmptyResults: true,
                         testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build Container Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile in the repo root
                    dockerImage = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Authenticate and push the image
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push("${DOCKER_TAG}")
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                // SSH into the deployment server and run the deploy script
                sshagent(credentials: ['deploy-server-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} \
                            'sudo /opt/petclinic/deploy.sh ${DOCKER_IMAGE}:${DOCKER_TAG}'
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. Application deployed at https://petclinic.local"
        }
        failure {
            echo "Pipeline failed. Check the logs above for details."
        }
        always {
            // Clean up the Docker image from the Jenkins server to save disk space
            sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
        }
    }
}
