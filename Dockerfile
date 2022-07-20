## Symfony Web Application
FROM composer:latest AS symfony-web-application

RUN apk add --no-cache bash && \
    curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash && \
    apk add symfony-cli acl
CMD ["tail", "-f", "/dev/null"]

## Nginx
FROM nginx as nginx
COPY docker/nginx/conf.d/nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /app/public
CMD ["nginx", "-g", "daemon off;"]


## PHP-FPM
FROM php:fpm-alpine AS php_fpm

RUN set -eux; \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS icu-dev libzip-dev zlib-dev; \
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) intl zip; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .phpexts-rundeps $runDeps; \
	apk del .build-deps

RUN ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY docker/php-fpm/conf.d/php.prod.ini $PHP_INI_DIR/conf.d/php.prod.ini
COPY docker/php-fpm/php-fpm.d/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf

WORKDIR /app

CMD ["php-fpm"]
