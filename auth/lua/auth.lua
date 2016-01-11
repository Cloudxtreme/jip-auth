local auth_dict =  ngx.shared.auth_dict

if ngx.var.remote_user == nil then
    ngx.exit(401)
end

local auth_info = ngx.req.get_headers()['Authorization'] 
auth_info = string.gsub(auth_info,"Basic (.*)","%1")
auth_info = ngx.decode_base64(auth_info)
local a,b,user_name,user_passwd = string.find(auth_info,"(.*):(.*)")
local registry_user_passwd = auth_dict:get(user_name)
if registry_user_passwd ~= user_passwd then
	ngx.exit(401)
end
