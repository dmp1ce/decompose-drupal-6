php:
  build: containers/php/.
  volumes_from:
    - source
    - data
  links:
    - db
  environment:
    TERM: dumb
  log_driver: "journald"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
nginx:
  build: containers/nginx/.
  links:
    - php
  volumes_from:
    - source
    - data
  environment:
    - VIRTUAL_HOST={{PROJECT_NGINX_PROXY_VIRTUAL_HOSTS}}
{{#PRODUCTION}}
    - LETSENCRYPT_HOST={{PROJECT_NGINX_PROXY_VIRTUAL_HOSTS}}
    - LETSENCRYPT_EMAIL=dave@upgradeya.com
{{/PRODUCTION}}
  log_driver: "journald"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
db:
  image: mariadb
  environment:
    MYSQL_ROOT_PASSWORD: {{PROJECT_DB_ROOT_PASSWORD}}
    MYSQL_USER: {{PROJECT_DB_USER}}
    MYSQL_PASSWORD: {{PROJECT_DB_PASSWORD}}
    MYSQL_DATABASE: {{PROJECT_DB_DATABASE}}
    TERM: dumb
  log_driver: "journald"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
# Data containers
source:
  build: containers/source/.
  volumes:
    - {{#DEVELOPMENT}}{{PROJECT_SOURCE_HOST_PATH}}:{{/DEVELOPMENT}}{{PROJECT_SOURCE_CONTAINER_PATH}}
  command: "true"
  labels:
    - "data_container=true"
  log_driver: "journald"
data:
  build: containers/data/.
  command: "true"
  labels:
    - "data_container=true"
  log_driver: "journald"
# Backup
backup:
  build: containers/backup/.
  command: "/home/duply/backup_service"
  volumes_from:
    - data
    - backup_data
  links:
    - db
  log_driver: "journald"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
backup_data:
  build: containers/backup_data/.
  command: "true"
  labels:
    - "data_container=true"
  log_driver: "journald"

# vim:syntax=yaml
