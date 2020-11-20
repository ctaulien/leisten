FROM perl:latest

RUN apt-get upgrade -y
RUN apt-get update -y
RUN apt-get install -y sudo vim
RUN cpanm Data::Printer
RUN cpanm Math

WORKDIR /root/
