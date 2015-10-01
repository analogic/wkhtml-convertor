FROM ubuntu:trusty
MAINTAINER info@analogic.cz

# enable multiverse
RUN sed -r -i 's/^(# *)?deb[ -].+trusty-?.+$/\0 multiverse/' /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y xorg libssl-dev libxrender-dev wget gdebi php5-cli php5-fpm nginx-light supervisor fontconfig ttf-mscorefonts-installer
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2/wkhtmltox-0.12.2_linux-trusty-amd64.deb
RUN gdebi --n wkhtmltox-0.12.2_linux-trusty-amd64.deb && rm wkhtmltox-0.12.2_linux-trusty-amd64.deb

# install ttf-mscorefonts-installer
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get -q -y update && \
    apt-get -q -y install ttf-mscorefonts-installer && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/cache/* && \
	bash -c '[[ -f /usr/share/fonts/truetype/msttcorefonts/Arial.ttf ]] && exit 0 || echo "msttcorefonts error" >&2 && exit 1'

RUN apt-get remove -y wget gdebi && apt-get autoremove -y && apt-get clean -y

## add resources
COPY index.php /var/www/html/index.php
COPY nginx-host.conf /etc/nginx/sites-available/default
COPY supervisor.conf /etc/supervisor/conf.d/nginxphp.conf

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]