# authorize-rest.lua
Authorize REST API by lia script for nginx-lua-module

# Basic
Authorize use the token in the HTTP-header Authorization:
```  
  Authorization: Token 79a628b2d968cfe1a7f9c5e398f6b96a 
```  
  
The Token is md5 checksum of the HTTP request body for POST or PUT method or md5 checksum of the URI for GET or DELETE method    



# Requitments
lua-nginx-module      https://github.com/openresty/lua-nginx-module/  for single API-Key on the API

lua-cjson-module      https://github.com/openresty/lua-cjson/         for API-Key for each user

lua-resty-mysql       https://github.com/openresty/lua-resty-mysql    if keys store in the MySQL      

# Usage
Install the lua-nginx-module. If necessary the protect access to the API by location /api, You must the next nginx config```



```  location /api {

			client_max_body_size 50k;
			client_body_buffer_size 50k;

			 access_by_lua_file /path/to/access.lua;

			fastcgi_split_path_info ^(.+\.php)(/.+)$;
			fastcgi_pass 127.0.0.1:9000;

			include fastcgi_params;
			fastcgi_param   DOCUMENT_ROOT /path/to/www/dir;
			fastcgi_param   SCRIPT_FILENAME /path/to/www/dir/index.php;
			fastcgi_index index.php;
		}
```

Any HTTP request with fail digest authentification has 403 HTTP return code (Forbidden). For HTTP requests of true API-Token  has access to backend. For exampe the backend is PHP script. So, Your can to use uswgi protocol:
```
  	client_max_body_size       50k;
		client_body_buffer_size    50k;

		access_by_lua_file /path/to/access.lua;

    uwsgi_pass          unix:///tmp/uwsgi.sock;
    include             uwsgi_params;

    uwsgi_param             UWSGI_SCRIPT            webapp;
    uwsgi_param             UWSGI_CHDIR             /usr/local/www/app1;
```
