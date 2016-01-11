local mysql_info = require "mysql_info"
local cjson = require "cjson"
local random_passwd = require "random_passwd"
local auth_dict =  ngx.shared.auth_dict


ngx.req.read_body()
local req_table = cjson.decode(ngx.req.get_body_data())

ngx.log(ngx.ERR,ngx.req.get_body_data())

ngx.log(ngx.ERR,req_table["user_name"])

if req_table["user_name"] == nil or req_table["user_name"] == "admin" then
    ngx.exit(400)
    return
end

ngx.log(ngx.ERR,"here")

local registry_info = {}
if ngx.var.request_method == "GET"  then
    local user_passwd = auth_dict:get(req_table["user_name"])
    if user_passwd then
        registry_info.user_name = req_table["user_name"]
        registry_info.user_passwd = user_passwd
        registry_info.ret = 0
        registry_info.res = "success"
    else
        registry_info.ret = 0
        registry_info.res = "success"
        registry_info.user_name = req_table["user_name"]
        registry_info.user_passwd = random_passwd.get_random_passwd()
        local sql_ret,sql_res = mysql_info.syn_vars(registry_info.user_name,registry_info.user_passwd)
        if sql_ret ~= 0 then
            registry_info.ret = 1
            registry_info.res = sql_res
        end
        local dict_ret,dict_res = auth_dict:set(registry_info.user_name,registry_info.user_passwd)
        if not dict_ret then
            registry_info.ret = 1
            registry_info.res = dict_res
        end
    end

    ngx.say(cjson.encode(registry_info))
end

local registry_info = {}
if ngx.var.request_method == "POST" then
    if req_table["user_passwd"] == nil then
        ngx.exit(400)
        return
    end
    registry_info.ret = 0
    registry_info.res = "success"
    registry_info.user_name = req_table["user_name"]
    registry_info.user_passwd = req_table["user_passwd"]
    local sql_ret,sql_res = mysql_info.syn_vars(registry_info.user_name,registry_info.user_passwd)
    if sql_ret ~= 0 then
        registry_info.ret = 1
        registry_info.res = sql_res
    end
    local dict_ret,dict_res = auth_dict:set(registry_info.user_name,registry_info.user_passwd)
    if not dict_ret then
        registry_info.ret = 1
        registry_info.res = dict_res
    end
    ngx.say(cjson.encode(registry_info))
end

