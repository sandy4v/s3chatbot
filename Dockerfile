FROM jenkins/jenkins:lts

USER root

# Install necessary tools (including Python and AWS CLI)
RUN apt-get update
RUN apt-get install -y nodejs npm python3 python3-pip awscli  # Install python3 and pip

# Verify installation
RUN node -v
RUN npm -v
RUN aws --version

USER jenkins