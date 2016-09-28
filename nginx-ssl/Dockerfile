FROM nginx:1.11.4
MAINTAINER Piotr Skindel "piotr.skindel@intel.com"

COPY mime.types /etc/nginx/mime.types
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl.conf /etc/nginx/
COPY site.conf /etc/nginx/sites-enabled/

RUN mkdir -p /etc/nginx/ssl

EXPOSE 443
CMD ["nginx"]
