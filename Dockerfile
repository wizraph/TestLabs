FROM ubuntu:16.04
RUN mkdir -p /home/se/.aws/
COPY awssecret.json /home/se/.aws/credentials
RUN apt-get update && \
    apt-get install -y apache2=2.4.18-2ubuntu3.17
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /var/www /var/log/apache2 /etc/apache2
USER appuser
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
