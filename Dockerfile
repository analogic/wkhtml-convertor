FROM ubuntu:trusty
MAINTAINER info@analogic.cz

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y xorg libssl-dev libxrender-dev wget gdebi php5-cli php5-fpm nginx-light supervisor ttf-mscorefonts-installer ttf-xfree86-nonfree && fc-cache -f -v
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2/wkhtmltox-0.12.2_linux-trusty-amd64.deb
RUN gdebi --n wkhtmltox-0.12.2_linux-trusty-amd64.deb && rm wkhtmltox-0.12.2_linux-trusty-amd64.deb
RUN apt-get remove -y wget gdebi && apt-get autoremove -y && apt-get clean -y

## add resources
COPY index.php /var/www/html/index.php
COPY nginx-host.conf /etc/nginx/sites-available/default
COPY supervisor.conf /etc/supervisor/conf.d/nginxphp.conf

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]