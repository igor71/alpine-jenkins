# Jenkins Docker, Jenkins Running As Service

FROM jenkins/jenkins:2.107.2-alpine

LABEL MAINTAINER="Igor Rabkin<igor.rabkin@xiaoyi.com>"


##################################
#            Set ARG's           #
##################################

ARG JENKINS_BRANCH=2.107.2-alpine

#######################
# Update repositories #
#######################

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt-get update


#################################################
#          Set Time Zone Asia/Jerusalem         #
################################################# 

ENV TZ=Asia/Jerusalem
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


################################################
#     Basic desktop environment                #
################################################

# Locale, language
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


#################################################
#     Very basic installations                  #
#################################################

RUN apt-get install -y --no-install-recommends \
    curl \
    wget \
    tree \
    htop \
    vim \
	nano \
	tzdata \
	pv \
	iputils-ping \
    net-tools \
	screen \
	sudo \
	mc && \
    rm -rf /var/lib/apt/lists/*
    
 RUN apk -U add docker

	
#################################################
# PID 1 - signal forwarding and zombie fighting #
#################################################

# Add Tini
ARG TINI_VERSION=v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini


##############################################################
# Upgrade packages on image & Installing and Configuring SSH #
##############################################################

RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin 
	
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd 

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile	


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
| with Jenkins ${TF_BRANCH} running in service mode |\n\
| with preinstalled most common plugins			 |\n\
|					         |\n\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
\n "\
	> /etc/motd

#####################
# Standard SSH Port #
#####################

EXPOSE 22

#####################
# Default commands  #
#####################

ENTRYPOINT ["/tini", "--"]
CMD ["/usr/sbin/sshd", "-D"]
RUN ["/bin/bash"]
