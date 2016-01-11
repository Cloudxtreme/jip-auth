local mysql = require "resty.mysql"

local _M = {}

_M.g_db = {host="172.17.0.26", port=3306, database="registry", user="root", password="zxc", pool=""}

--[[
use registry;
DROP TABLE IF EXISTS auth;
CREATE TABLE IF NOT EXISTS auth (
  user_name           varchar(32)       NOT NULL, 
  user_passwd         varchar(32)       NOT NULL,  
  ts                 TIMESTAMP          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY ( user_name )
);
commit;
]]--

local log = ngx.log
local ERR = ngx.ERR
local NOTICE = ngx.NOTICE
local NFO = ngx.INFO
local ERR_DB = 101





function _M.sync_db(db, sql, key, col)
   if not db then
	return nil
   end

   local ret = {}
   
   --print ( sql )
   res, err, errno, sqlstate = db:query(sql)

   if not res then
      ngx.log(ngx.ERR, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
      return nil
   end

   if not key then
      ret = res;
      return ret;
   end

   local r
   if col and #col == 1 then
      for i = 1, #res do
         r = res[i]
         ret[r[key]] = r[col[1]]
      end
      return ret;
   end

   for i = 1, #res do
      r = res[i]
      ret[r[key]] = r

      -- use r , instead of ret[r[key]] to avoid r[key]=nil error
      if col then
        for k in pairs(r) do 
          if not exist_in(k, col) then
            r[k] = nil
          end
        end
      end
   end
   return ret
end

function _M.update_db(sql)
   local db = mysql:new()
   db:set_timeout(10000) -- 2 sec


   local ok, err, errno, sqlstate = db:connect({
         host = _M.g_db.host,
         port = _M.g_db.port,
         database = _M.g_db.database,
         user = _M.g_db.user,
         password = _M.g_db.password,
         pool = _M.g_db.pool})

   if not ok then
      ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errno, " ", sqlstate)
      return ERR_DB, "failed to connect mysql"
   end

   res, err, errno, sqlstate = db:query(sql)
   if not res then
      ngx.log(ngx.ERR, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
      return ERR_DB, "failed to update auth"
   end

   local ok, err = db:set_keepalive()
   if not ok then
      ngx.log(ngx.ERR, "failed to set keepalive: ", err)
   end

   return 0
end
function _M.execute_sql(sql)
   local db = mysql:new()
   db:set_timeout(10000) -- 2 sec

   local ok, err, errno, sqlstate = db:connect({
         host = _M.g_db.host,
         port = _M.g_db.port,
         database = _M.g_db.database,
         user = _M.g_db.user,
         password = _M.g_db.password,
         pool = _M.g_db.pool})

   if not ok then
      ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errno, ", ", sqlstate)
      db:close()
      return false
   end
   local res, err, errno, sqlstate = db:query(sql)
   if not res then
      ngx.log(ngx.ERR, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
      db:close()
      return false
   end
   db:close()
   return true
end



function _M.syn_vars(user_name,user_passwd)

  local value_string= string.format("values ('%s','%s')", user_name, user_passwd )   
  local ret, res = _M.update_db("REPLACE into auth (user_name, user_passwd)" .. value_string)
  return ret, res

end


return _M
