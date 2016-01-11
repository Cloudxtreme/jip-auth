------------ sync data to shared dict ---------------
local delay = 20


local cjson = require "cjson"
local mysql = require "resty.mysql"
local mysql_info = require "mysql_info"
local auth_dict =  ngx.shared.auth_dict


local function sync_data(  )
	local db = mysql:new()
    db:set_timeout(10000) -- 2 sec
    local ok, err, errno, sqlstate = db:connect(mysql_info.g_db)
    
    if not ok then
       ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errno, " ", sqlstate)
       return
    end
    
    local tab_authinfo = mysql_info.sync_db(db, "select user_name, user_passwd from auth")
    ngx.log(ngx.DEBUG,"tab_authinfo:" .. cjson.encode(tab_authinfo))
    if tab_authinfo then
        for i,v in pairs(tab_authinfo) do
            auth_dict:set(v.user_name,v.user_passwd)
        end
    end
end

local function timer(premature)
    if not premature then
        sync_data()
        ngx.log(ngx.ERR, "success to create timer")
        local ok, err = ngx.timer.at(delay, timer)
        if not ok then
            ngx.log(ngx.ERR, "failed to create timer: ", err)
            return
        end
    end
end


local id = ngx.worker.id()
ngx.log(ngx.ERR,"id:" .. id)

if id ~= 1 then
    return
end


local ok, err = ngx.timer.at(delay, timer)
if not ok then
    ngx.log(ngx.ERR, "failed to create auth timer: ", err)
    return
end
ngx.log(ngx.ERR, "success to create auth timer")


