local _M={}

local function random( n,m )
	math.randomseed(os.clock()*math.random(1000000,9000000)+math.random(1000000,9000000))
	return math.random(n,m)
end
local function random_letter( len )
	local rt = ""
	for i=1,len,1 do
		rt = rt .. string.char(random(65,90))
	end
	return rt
end

function _M.get_random_passwd( )
	return random_letter(6)
end

return _M