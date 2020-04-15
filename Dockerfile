FROM debian:buster-slim
MAINTAINER Zedix

# Environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

# Install tools
RUN apt-get -qq update && \
  apt-get -yqq install \
  apt-utils \
  build-essential \
  curl \
  debconf \
  debconf-utils \
  default-mysql-client \
  default-mysql-server \
  gettext \
  git-core \
  graphicsmagick \
  libjpeg-turbo-progs libjpeg-progs \
  libpng-dev \
  locales \
  openssh-client \
  pngcrush optipng \
  rsync \
  unzip \
  vim \
  wget \
  && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

RUN \
 apt-get update &&\
 echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
 locale-gen en_US.UTF-8 &&\
 /usr/sbin/update-locale LANG=en_US.UTF-8 &&\
 echo "mysql-server mysql-server/root_password password root" | debconf-set-selections &&\
 echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections &&\
 curl -sSL https://deb.nodesource.com/setup_10.x | bash -

# Configure Sury PHP repository
RUN apt-get -qq update && \
  apt-get -yqq install apt-transport-https lsb-release ca-certificates && \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
  apt-get -qq update && apt-get -qqy upgrade && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Install PHP & extensions
RUN  \
 apt-get update &&\
 apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
  php7.4-apcu \
  php7.4-bcmath \
  php7.4-cli \
  php7.4-curl \
  php7.4-dom \
  php7.4-fpm \
  php7.4-gd \
  php7.4-imagick \
  php7.4-intl \
  php7.4-mbstring \
  php7.4-mysql \
  php7.4-xdebug \
  php7.4-xml \
  php7.4-zip &&\
 apt-get clean && apt-get --yes --quiet autoremove --purge &&\
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/*

RUN \
 sed -ri -e "s/^variables_order.*/variables_order=\"EGPCS\"/g" /etc/php/7.4/cli/php.ini &&\
 echo "\nmemory_limit=-1" >> /etc/php/7.4/cli/php.ini &&\
 echo "xdebug.max_nesting_level=250" >> /etc/php/7.4/mods-available/xdebug.ini

RUN \
 curl -sSL https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin &&\
 curl -sSL https://phar.phpunit.de/phpunit.phar -o /usr/bin/phpunit  && chmod +x /usr/bin/phpunit &&\
 curl -sSL https://codeception.com/codecept.phar -o /usr/bin/codecept && chmod +x /usr/bin/codecept &&\
 curl -sSL https://github.com/infection/infection/releases/download/0.12.0/infection.phar -o /usr/bin/infection && chmod +x /usr/bin/infection &&\
 npm install --no-color --production --global gulp-cli webpack mocha grunt yarn n &&\
 rm -rf /root/.npm /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/log/*
