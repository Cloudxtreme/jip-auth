local keystone_server = "10.8.65.30:5000"


local cjson = require "cjson"
--local auth_info = ngx.header.authorization 

if ngx.var.remote_user == nil then
    ngx.exit(401)
end

local auth_info = ngx.req.get_headers()['Authorization'] 
auth_info = string.gsub(auth_info,"Basic (.*)","%1")
auth_info = ngx.decode_base64(auth_info)
local a,b,user,passwd = string.find(auth_info,"(.*):(.*)")
ngx.log(ngx.ERR,"user:" .. user," passwd:" .. passwd)


ngx.req.set_header("Content-Type", "application/json;charset=utf8");
ngx.req.set_header("Accept", "application/json");


--- curl -i  -d '{"auth": {"tenantName": "", "passwordCredentials": {"username": "registry", "password": "zxc"}}}' -H "Content-type: application/json" http://localhost:5000/v2.0/tokens

local body = '{"auth": {"tenantName": "", "passwordCredentials": {"username":"'  .. user .. '", "password":"' .. passwd ..'"}}}'
ngx.log(ngx.ERR,"body:" .. body)


local keystone = "http://" .. keystone_server .. "/v2.0/tokens"

local res = ngx.location.capture('/keystone', {
    method = ngx.HTTP_POST,
    body = body,
    args = {},
    vars = {keystone = keystone}
});

ngx.log(ngx.ERR,"res:" .. cjson.encode(res))

if res.status == 401 then
    ngx.exit(401)
end
