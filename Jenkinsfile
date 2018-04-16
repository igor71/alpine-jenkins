pipeline {
  agent {label 'alpine-jenkins'}
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t liatrio/jenkins-alpine:2.107 .'
            }
        }
        stage('Save docker image as achive') {
            steps {
                sh 'docker save liatrio/jenkins-alpine:2.107 | pv | cat > /media/common/DOCKER_IMAGES/liatrio-jenkins-alpine-2.107.tar'
            }
        }
    }
}
