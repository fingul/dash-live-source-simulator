#FROM httpd:2-alpine
FROM alpine:3.6

RUN apk add --no-cache apache2 apache2-mod-wsgi bash python2 wget

ADD https://raw.githubusercontent.com/docker-library/httpd/656b3859734d70b47386fd8bac58d5f719df596b/2.4/alpine/httpd-foreground /usr/local/bin/httpd-foreground
RUN chmod a+rx /usr/local/bin/httpd-foreground

ADD media/testpic_2s.tar.gz /var/www/localhost/htdocs/dash/vod/
COPY setup/dash.conf /etc/apache2/conf.d/dash.conf
COPY setup/mod_wsgi_dashlivesim.conf /etc/apache2/conf.d/dashlivesim.conf
COPY dashlivesim /usr/local/bin/mod_wsgi/dashlivesim
#COPY dashlivesim/tests/vod_cfg/testpic.cfg /var/www/localhost/htdocs/livesim_vod_configs/testpic.cfg
#COPY dashlivesim/tests/testpic /var/www/localhost/htdocs/dash/vod/testpic
COPY media/testpic_2s.cfg /var/www/localhost/htdocs/livesim_vod_configs/testpic_2s.cfg
RUN rm /var/www/run && \
  mkdir /var/www/run && \
  chown 100:101 /var/www/run && \
  sed -ri \
       -e 's!^(\s*PidFile)\s+\S+!\1 /var/www/run/httpd.pid!g' \
       "/etc/apache2/conf.d/mpm.conf"

#RUN wget --limit-rate=250k -r -nH --cut-dirs=2 --level=1 --no-parent -P /var/www/localhost/htdocs/dash/vod/ http://vm2.dashif.org/dash/vod/testpic_2s/A48/

#RUN wget --limit-rate=250k -r -nH --cut-dirs=2 --level=1 --no-parent -P /var/www/localhost/htdocs/dash/vod/ http://vm2.dashif.org/dash/vod/testpic_2s/V300/

#RUN wget -P /var/www/localhost/htdocs/dash/vod/testpic_2s/ http://vm2.dashif.org/dash/vod/testpic_2s/Manifest.mpd

EXPOSE 80
CMD ["httpd-foreground"]
