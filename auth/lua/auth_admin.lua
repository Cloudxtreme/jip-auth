if ngx.var.remote_user == nil then
    ngx.exit(401)
end

local auth_info = ngx.req.get_headers()['Authorization'] 
auth_info = string.gsub(auth_info,"Basic (.*)","%1")
auth_info = ngx.decode_base64(auth_info)
local a,b,user_name,user_passwd = string.find(auth_info,"(.*):(.*)")
ngx.log(ngx.DEBUG,"user_name:" .. user_name," user_passwd:" .. user_passwd)

if user_name ~= "admin" then
    ngx.exit(403)
end

if user_passwd ~= "admin" then
    ngx.exit(401)
end