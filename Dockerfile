FROM jenkins/jenkins:lts

USER root

# Install necessary tools (including Python and AWS CLI)
RUN apt-get update
RUN apt-get install -y nodejs npm python3 python3-pip awscli wget unzip # Install wget and unzip

# Install Terraform
ARG TERRAFORM_VERSION=1.7.4
ARG TERRAFORM_SHA256=your_terraform_sha256_here # !!! REPLACE THIS WITH THE ACTUAL SHA256 CHECKSUM !!!

RUN wget -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && echo "${TERRAFORM_SHA256}  /tmp/terraform.zip" | sha256sum -c \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm /tmp/terraform.zip

# Verify installation
RUN node -v
RUN npm -v
RUN aws --version
RUN terraform --version

USER jenkins