# Start from an outdated version of Ubuntu, e.g., 16.04
FROM ubuntu:16.04

# Avoid prompting during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install an outdated and vulnerable software package, e.g., Apache HTTP Server 2.4.18
RUN apt-get update && \
    apt-get install -y apache2=2.4.18-2ubuntu3.17

# Install additional vulnerable libraries
# Example: An old version of OpenSSL with known vulnerabilities
RUN apt-get install -y openssl=1.0.2g-1ubuntu4.17

# Example: Installing a vulnerable version of libpng
RUN apt-get install -y libpng12-0=1.2.54-1ubuntu1.1

# Expose port 80 for the web server
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
