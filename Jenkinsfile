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
              withDockerRegistry([ credentialsId: "DockeHub", url: "https://hub.docker.com/r/igor71/jenkins-alpine/" ]) {
                sh 'docker push yi/jenkins-alpine:2.107'
              }
            }
        }
    }
}
