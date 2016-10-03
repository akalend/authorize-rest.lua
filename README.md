# authorize-rest.lua
Authorize REST API by lia script for nginx-lua-module

# Basic
Authorize use the token in the HTTP-header Authorization:

  Authorization: Token 79a628b2d968cfe1a7f9c5e398f6b96a 
  
The Token is md5 checksum of the HTTP request body for POST or PUT method or md5 checksum of the URI for GET or DELETE method    

# Requitments
lua-nginx-module      https://github.com/openresty/lua-nginx-module/  for single API-Key on the API
lua-cjson-module      https://github.com/openresty/lua-cjson/         for API-Key for each user
lua-resty-mysql       https://github.com/openresty/lua-resty-mysql    if keys store in the MySQL      
