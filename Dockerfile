FROM ubuntu:16.04
RUN mkdir -p /home/se/.aws/
COPY awssecret.json /home/se/.aws/credentials
RUN apt-get update && \
    apt-get install -y apache2=2.4.18-2ubuntu3.17
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
