pipeline {
  agent {label 'alpine-jenkins'}
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t yi/jenkins-alpine:2.107 .'
            }
        }
        stage('Push to DockerHub') {
          when {
          branch 'master'
               }
            steps {
              withDockerRegistry([ credentialsId: "557b24c8-ef4d-4132-8de4-1890c68a3b82", url: "" ]) {
              sh 'docker push yi/jenkins-alpine:2.107'
               }
            }
        }
    }
}
