FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install wget unzip -y && \
    wget https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip \
    && unzip terraform_1.0.9_linux_amd64.zip 

RUN mv terraform /usr/local/bin/

RUN echo $(terraform -v)

WORKDIR /app

COPY . .

CMD [ "tail", "-f", "/dev/null" ]