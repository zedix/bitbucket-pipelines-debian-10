# bitbucket-pipelines-debian-10(-php7.4)

[Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) [Docker](https://www.docker.com/) image based on [Debian 10 _Buster_](https://www.debian.org/releases/stretch/) with [PHP 7.4](http://php.net/) and Node.JS 13.x.

## Example `bitbucket-pipelines.yml`

```yaml
image: zedix/bitbucket-pipelines-debian-10
pipelines:
  default:
    - step:
        script:
          - localedef -i fr_FR -f UTF-8 fr_FR.utf8
          - php -v
          - php -r "file_exists('.env') || copy('.env.testing', '.env');"
          - composer validate --no-interaction
          - composer install --no-interaction --no-progress --no-suggest --prefer-dist
          - php artisan key:generate
          - php artisan migrate:refresh --seed --env=testing
          - vendor/bin/phpunit -v --colors=never --stderr
        services:
          - mysql

definitions:
  services:
    mysql:
      image: mysql:5.7
      environment:
        MYSQL_DATABASE: 'db_test_xxx'
        MYSQL_USER: 'xxx'
        MYSQL_PASSWORD: 'xxx'
        MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
```
