#dockerfile for nginx/php5-fpm
FROM ubuntu:14.04
MAINTAINER moh.ayman.ibrahim@gmail.com
ENV CACHED_FLAG 1

# Install nginx and php-fpm
RUN apt-get update -qq && apt-get -y upgrade
RUN apt-get -y -qq install nginx
VOLUME /var/www/app

# Adding the configuration files
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/default.conf /etc/nginx/conf.d/

# Expose the port 80
#EXPOSE 80

# Run nginx
ENTRYPOINT [ "/usr/sbin/nginx" ]
