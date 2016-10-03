local mysql = require "resty.mysql"

local db = mysql:new()
	local ok, err, errcode, sqlstate = db:connect({ 
	host = "127.0.0.1", 
	port = 3306,
	database = "temp",
	user = "akalend",
	password = "12345"})

if not ok then
		ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
		return ngx.exit(500)
end

res, err, errcode, sqlstate = db:query("select id,token from users;")
	
if not res then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
		return ngx.exit(500)
end

local keys = ngx.shared.keys


for n,row in pairs(res) do
	keys:set(row.id, row.token)
end

