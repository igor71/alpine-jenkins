pipeline {
  agent {label 'alpine-jenkins'}
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t yi/jenkins-alpine:2.107 .'
            }
        }
        stage('Push to DockerHub') {
            steps {
              docker.withRegistry('https://registry.hub.docker.com', 'DockerHub') {
              sh 'docker push yi/jenkins-alpine:2.107'
               }
            }
        }
    }
}
