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
### Single API KEY
Install the lua-nginx-module. If necessary the protect access to the API by location /api, You must the next nginx config
```
location /api {

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

Any HTTP request with fail digest authentification has 403 HTTP return code (Forbidden). For HTTP requests of true API-Token  has access to backend. For first exampe the backend is PHP script. So, Your can to use uswgi protocol, for Flask or Django for example:

```

  	client_max_body_size       50k;
	client_body_buffer_size    50k;

	access_by_lua_file /path/to/access.lua;

	uwsgi_pass          unix:///tmp/uwsgi.sock;
	include             uwsgi_params;

	uwsgi_param             UWSGI_SCRIPT            webapp;
	uwsgi_param             UWSGI_CHDIR             /usr/local/www/app1;
```

You must the set API Key in the access.lua scripl, line 2. The value "12345" by default:
```
local key = "12345" 
```
### Multiple API KEYS
The API KEYs store in the shared memory. The initial load API Keys must be by lua init phase or call some init script. If the API KEYs store in the Database (MySQL or PosgreSQL), You can load from module. For example, You can upgrade API Keys one time in Day and call by cron the
```
curl http://127.0.0.1/init-api-keys
```
The User Id can be from part of url or from body. If user_id is part of body, You can to use by parsing json in the rewrithe pahese and set nginx var $user_id:
```
set_by_lua $user_id ' 
	cjson = require "cjson"
	ngx.req.read_body()  -- explicitly read the req body
	local body = ngx.req.get_body_data()
	if body then
		-- parsing json body for  {user_id : 123, address: .... }
		local body = cjson.decode(body)
		return body.user_id
	end
	return
'; 

```
The nginx config, for user_id as part from url:
```
http{
	# include MySQL resty lib
	lua_package_path "/home/akalend/src/lua-resty-mysql/lib/?.lua;;";

	server {
		# declare shared table keys 10 Mb
		lua_shared_dict keys 10m;

        	listen       80;
        	server_name  localhost;

	  	location ~ ^/api/(\w+)/ {
			
			# check user_id from first part url:
			# example /api/123/get-friends

			client_max_body_size 50k;
			client_body_buffer_size 50k;

			#so you can to use set_by_lua fro $user_id 
			set $user_id $1;
			
			access_by_lua_file /path/to/access.shared_key.lua;

			fastcgi_split_path_info ^(.+\.php)(/.+)$;
			fastcgi_pass 127.0.0.1:9000;

			include fastcgi_params;

			fastcgi_param   USER $user;
			fastcgi_param   DOCUMENT_ROOT /path/to/www/dir;
			fastcgi_param   SCRIPT_FILENAME /path/to/www/dir/index.php;
			fastcgi_index index.php;

	   	}

		location /init-api-keys {
			allow 127.0.0.1;
			deny all;

			content_by_lua_file /path/to/init.lua;	
		}
	}
}
```
