# Drupal 6 nginx config
# Reference: http://wiki.nginx.org/Drupal
server {
  server_name {{PROJECT_NGINX_VIRTUAL_HOST}};
  root {{PROJECT_SOURCE_CONTAINER_PATH}}; ## <-- Your only path reference.

  # For large file uploads
  # client_max_body_size 10m;

  # Enable compression, this will help if you have for instance advagg‎ module
  # by serving Gzip versions of the files.
  gzip_static on;

  location = /favicon.ico {
    log_not_found off;
    access_log off;
  }

  location = /robots.txt {
    allow all;
    log_not_found off;
    access_log off;
  }

  location = /version.txt {
    allow all;
    log_not_found off;
    access_log off;
  }
 
  # Very rarely should these ever be accessed outside of your lan
  location ~* \.(txt|log)$ {
    allow 192.168.0.0/16;
    deny all;
  }
 
  location ~ \..*/.*\.php$ {
    return 403;
  }
 
  # No no for private
  location ~ ^/sites/.*/private/ {
    return 403;
  }
 
  # Block access to "hidden" files and directories whose names begin with a
  # period. This includes directories used by version control systems such
  # as Subversion or Git to store control files.
  location ~ (^|/)\. {
    return 403;
  }
 
  location / {
    # This is cool because no php is touched for static content
    try_files $uri @rewrite;
  }
 
  location @rewrite {
    # For Drupal 6 and below:
    # Some modules enforce no slash (/) at the end of the URL
    # Else this rewrite block wouldn't be needed (GlobalRedirect)
    rewrite ^/(.*)$ /index.php?q=$1;
  }
 
  location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $request_filename;
    fastcgi_intercept_errors on;
    fastcgi_pass php:9000;
  }
 
  # Fighting with Styles? This little gem is amazing.
  location ~ ^/sites/.*/files/imagecache/ {
      try_files $uri @rewrite;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires max;
    log_not_found off;
  }
}

# Redirect alternative domain names.
server {
  server_name {{PROJECT_NGINX_VIRTUAL_HOST_ALTS}};
  # $scheme will get the http protocol
  # and 301 is best practice for tablet, phone, desktop and seo
  return 301 $scheme://{{PROJECT_NGINX_VIRTUAL_HOST}}$request_uri;
}

# vim:syntax=nginx
