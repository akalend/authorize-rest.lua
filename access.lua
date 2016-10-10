local method = ngx.req.get_method()
local key = "12345"     
local h = ngx.req.get_headers()
local token = h.Authorization

if token == nil then
	ngx.exit(ngx.HTTP_FORBIDDEN)
end

md_hash = token:match("([^Token ].+)")

if  method == "POST" or method == "PUT" then 
	ngx.req.read_body()  -- explicitly read the req body
	local body = ngx.req.get_body_data()
	if body then
			
		local data = body .. key

		if ngx.md5(data) ~= md_hash then
			ngx.exit(ngx.HTTP_FORBIDDEN)
		end
		return
	end

	ngx.exit(ngx.HTTP_FORBIDDEN)
	return
end

if  method == "GET" or method == "DELETE" then 
	local str = ngx.var.uri .. '?' .. ngx.var.args .. key

	if md_hash == ngx.md5(str) then
		return
	end	

	ngx.exit(ngx.HTTP_FORBIDDEN)
	return
end

ngx.exit(ngx.HTTP_FORBIDDEN)
