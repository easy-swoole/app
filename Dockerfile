FROM php:7.2

MAINTAINER winton <wiwang@foxmail.com>

# Timezone
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

# Libs
RUN apt-get update \
    && apt-get install -y \
        curl \
        less \
        wget \
        git \
        zip \
        libz-dev \
        libssl-dev \
        libnghttp2-dev \
        libpcre3-dev \
    && apt-get clean \
    && apt-get autoremove

RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups

# Redis extension
RUN pecl install redis && docker-php-ext-enable redis && pecl clear-cache

# Hiredis
RUN wget https://github.com/redis/hiredis/archive/v0.13.3.tar.gz -O hiredis.tar.gz \
    && mkdir -p hiredis \
    && tar -xf hiredis.tar.gz -C hiredis --strip-components=1 \
    && rm hiredis.tar.gz \
    && ( \
        cd hiredis \
        && make -j$(nproc) \
        && make install \
        && ldconfig \
    ) \
    && rm -r hiredis

# PDO extension
RUN docker-php-ext-install pdo_mysql

# Bcmath extension
RUN docker-php-ext-install bcmath

# pcntl extension
RUN docker-php-ext-install pcntl

# zip extension
RUN docker-php-ext-install zip 

# Swoole extension
RUN pecl install swoole-4.0.1 \
    && docker-php-ext-enable swoole

#RUN composer create-project easyswoole/app /var/www/es

ADD . /var/www/es

WORKDIR /var/www/es

EXPOSE 9501

CMD ["php", "vendor/easyswoole/easyswoole/bin/easyswoole", "start"]
