pipeline {
  agent {label 'alpine-jenkins'}
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t yi/jenkins-alpine:2.107 .'
            }
        }
        stage('Save docker image as archive') {
            steps {
          withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DockerHubPassword', usernameVariable: 'DockerHubUser')]) {
          sh "docker login -u ${env.DockerHubUser} -p ${env.DockerHubPassword}"
          sh 'docker push yi/jenkins-alpine:2.107'
            }
        }
    }
}
