FROM abiosoft/caddy

ADD Caddyfile /etc/Caddyfile
ADD public/ /srv

EXPOSE 2015
