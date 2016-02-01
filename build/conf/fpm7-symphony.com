location ~ \.php(/|$) {

             try_files $uri /app.php$is_args$args;

             proxy_read_timeout 1200;
             proxy_connect_timeout 1200;


             fastcgi_buffers 16 16k; 
             fastcgi_buffer_size 32k;

             fastcgi_pass php7-fpm-sock;
             fastcgi_index app.php;
             fastcgi_split_path_info ^(.+\.php)(/.*)$;
             fastcgi_param  PHP_VALUE $php_value;
             fastcgi_param  PHP_ADMIN_VALUE $php_admin_value;
             include fastcgi_params;
             fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
             fastcgi_param SERVER_NAME $http_host;
             fastcgi_ignore_client_abort on;
}
