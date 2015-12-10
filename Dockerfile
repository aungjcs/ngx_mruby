FROM ubuntu:14.04
MAINTAINER jcs aung<thetwin_a@japacom.co.jp>

RUN apt-get update && apt-get install aptitude vim gcc git wget curl make libc6 libpcre3 libpcre3-dev libssl0.9.8 libssl-dev zlib1g lsb-base bison -y

# install ruby and rake
RUN cd /tmp && \
  wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz && \
  tar zxvf ruby-2.1.5.tar.gz && \
  cd ruby-2.1.5 && \
  ./configure && \
  make && \
  sudo make install

# RUN curl http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
# RUN echo 'deb http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list
# RUN echo 'deb-src http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list

# RUN apt-get update && apt-get install nginx -y

# nginx user
RUN sudo adduser --system --no-create-home --disabled-login --disabled-password --group nginx

# download nginx
RUN cd /tmp && \
  wget http://nginx.org/download/nginx-1.8.0.tar.gz && \
  tar zxvf ./nginx-1.8.0.tar.gz 

# down ngx_mruby and configure
RUN cd /tmp && \
  git clone git://github.com/matsumoto-r/ngx_mruby.git && \
  cd ngx_mruby/ && \
  git submodule init && \
  git submodule update && \
  ./configure --with-ngx-src-root=/tmp/nginx-1.8.0 && \
  make build_mruby && \
  make generate_gems_config

# build nginx and add ngx_mruby
RUN cd /tmp/nginx-1.8.0 && \
  ./configure \
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-file-aio \
  --with-http_spdy_module \
  --with-ipv6 \
  --add-module=/tmp/ngx_mruby \
  --add-module=/tmp/ngx_mruby/dependence/ngx_devel_kit && \
  make && sudo make install

# create necessary directory for nginx
RUN mkdir /var/cache/nginx && mkdir /etc/nginx/conf.d && \
  chown nginx:nginx /var/cache/nginx

# add conf files
ADD nginx.conf /etc/nginx/nginx.conf
ADD mruby.conf /etc/nginx/conf.d/mruby.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
