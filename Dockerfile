# Jenkins Docker, Jenkins Running As Service

FROM jenkins/jenkins:2.107.2-alpine

LABEL MAINTAINER="Igor Rabkin<igor.rabkin@xiaoyi.com>"


##################################
#            Set ARG's           #
##################################

ARG JENKINS_VERSION=2.107.2-alpine

#################################################
#          Set Time Zone Asia/Jerusalem         #
################################################# 

ENV TZ=Asia/Jerusalem
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


#################################################
#            Very basic installations           #
#################################################

RUN apk -U add docker

	
########################################
#    Setup jenkins user to the image   #
########################################

RUN useradd -m -d /home/jenkins -s /bin/bash jenkins &&\
    echo "jenkins:jenkins" | chpasswd 
		
# Add the users to sudoers group
RUN echo "jenkins  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers
      
# Set full permission for jenkins folder
RUN chmod -R 777 /home/jenkins


###########################
# Install Jenkins Plugins #
###########################

USER jenkins
RUN /usr/local/bin/install-plugins.sh \
  blueocean \
  build-environment \
  cloudbees-folder \
  config-file-provider \
  credentials-binding \
  credentials \
  docker-plugin \
  docker-slaves \
  envinject \
  git \
  greenballs \
  groovy \
  job-dsl \
  jobConfigHistory \
  pam-auth \
  pipeline-utility-steps \
  nexus-artifact-uploader \
  workflow-aggregator \
  subversion

COPY resources/basic-security.groovy /usr/share/jenkins/ref/init.groovy.d/basic-security.groovy
COPY resources/maven-global-settings-files.xml /usr/share/jenkins/ref/maven-global-settings-files.xml
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER root


################################################################
# Add docker container welcome message with instructions       #
# Message will work only if docker running in interactive mode #
################################################################

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' \
	>> /etc/bash.bashrc \
	; echo "\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
|						 |\n\
| Docker container running Ubuntu		 |\n\
| with Jenkins ${JENKINS_VERSION} running in service mode |\n\
| with preinstalled most common plugins			 |\n\
|					         |\n\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
\n "\
	> /etc/motd

