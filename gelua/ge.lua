FONT_SIZE_NORMAL = 0
FONT_SIZE_SMALL = 1
FONT_SIZE_LARGE = 2

CENTER = -2147483647 + 1

DRAW_ADJUST = 1

ORIGIN_TOPLEFT = 0
ORIGIN_CENTER = 1



_real_geImage_load = geImage.load
geImage.load = function(path)
	local img = _real_geImage_load(path)
	img:TextureMode(GE_LINEAR)
	return img
end


screen = {}
sfx = {}
game = {}

screen.shader2dv = ""
screen.shader2df = ""
screen.font = {}

screen.exit = 0
screen.timers = {}

screen.setLocale = function(locale)
	dofile("languages/" .. locale .. ".lua")
end

screen.registerTimer = function(ms, fct, param)
	local i = 1
	local ok = false
	for k = 1, #screen.timers do
		i = k
		if screen.timers[k].used == false then
			ok = true
			break
		end
	end
	if ok == false then
		if #screen.timers > 0 then
			i = i + 1
		end
		screen.timers[i] = {}
	end
	screen.timers[i].used = true
	screen.timers[i].ms = ms
	screen.timers[i].fct = fct
	screen.timers[i].param = param
	screen.timers[i].t = 0
	return i
end

screen.unregisterTimer = function(i)
	if i >= 1 and i <= #screen.timers then
		screen.timers[i].used = false
	end
end

screen.update = function(t)
	for k,v in pairs(screen.timers) do
		if v.used == true and t - v.t >= v.ms then
			v.fct(v.param, t)
			v.t = t
		end
	end
end

screen.init = function(w, h, lowres)
	screen.width = w
	screen.height = h
	screen.lowres = false
	if lowres ~= 0 then
		screen.lowres = true
	end
	screen.size_factor = 1
	if screen.lowres == true then
		screen.size_factor = 2
	end
	screen.size = math.min(screen.width, screen.height)
	screen.hratio = screen.width / screen.size
	screen.vratio = screen.height / screen.size
	screen.defaultShader = geShader:getDefaultShader()
	if screen.shader == nil then
		screen.shader = geShader:getDefaultShader()
	end
end

screen.setDefaultShader = function(vert, frag)
	screen.shader = geShader.load(vert, frag)
end

screen.setFont = function(sz, file, factor)
	screen.font[sz] = geFont.load(file)
	local pixels = screen.size / 20
	if sz == FONT_SIZE_SMALL then
		pixels = pixels * 0.75
	elseif sz == FONT_SIZE_LARGE then
		pixels = pixels * 1.25
	end
	screen.font[sz].size = math.floor( pixels * factor )
	screen.print(0, 0, "") -- Update internal size
end

screen.draw = function(img, align, _x, _y)
	screen.shader:use()
	local x = 0
	local y = 0
	local flags = 0
	local size = 1.0
	if img.origin == ORIGIN_CENTER then
		flags = GE_BLIT_CENTERED
	end
	if align == DRAW_ADJUST then
		if img:width() * size < screen.width then
			size = screen.width / (img:width() * size)
		end
		if img:height() * size < screen.height then
			size = screen.height / (img:height() * size)
		end
		if img:width() > screen.width and img:height() > screen.height then
			if img:width() < img:height() then
				size = screen.width / img:width()
			else
				size = screen.height / img:height()
			end
		end
		x = screen.width / 2 - img:width() * size / 2
		y = screen.height / 2 - img:height() * size / 2
	end
	size = size * img.scale
	x = x + (_x or img.x) * screen.width
	y = y + (_y or img.y) * screen.height
	local f = math.floor
	if img.angle and img.angle ~= 0 then
		geImage.blitStretchedRotated(f(x), f(y), f(img.width * size), f(img.height * size), img, img.angle, 0, 0, img.width, img.height, flags)
	else
		geImage.blitStretched(f(x), f(y), f(img.width * size), f(img.height * size), img, 0, 0, img.width, img.height, flags)
	end
end

screen.print = function(x, y, str)
	local f = math.floor
	screen.defaultShader:use()
	if x == CENTER then
		w, h = screen.font[FONT_SIZE_NORMAL]:measureString(str)
		x = 0.5 - w / 2 / screen.width
	end
	screen.font[FONT_SIZE_NORMAL]:print(f(x * screen.width), f(y * screen.height), str)
	screen.shader:use()
end

screen.lprint = function(x, y, str)
	y = y * screen.font[FONT_SIZE_NORMAL].size / screen.height
	screen.print(x, y, str)
end




sfx.init = function()
	sfx.playing = false
end

sfx.bgm = function(file)
	sfx.playing = true
-- 	sfx.music = geMusic.load(file)
-- 	sfx.music.play()
end





local _G_metatable = getmetatable(_G) or {}

_G_metatable.__newindex = function(table, key, value)
	print("_G_metatable.__newindex(table, " .. key .. ", value)")
	rawset(table, key, value)
end

_G_metatable.__index = function(table, key)
	print("_G_metatable.__index(table, " .. key .. ")")
	if string.find(key, ".", 1, true) then
		local sub = string.sub(key, 1, string.find(key, ".", 1, true) - 1)
		return _G_metatable.__index(rawget(table, sub), string.sub(key, string.find(key, ".", 1, true) + 1, -1))
	end
	return rawget(table, key)
end

setmetatable(_G, _G_metatable)



function deepcopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end

	local no
	if type(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in next, o, nil do
		no[deepcopy(k, seen)] = deepcopy(v, seen)
		end
		setmetatable(no, deepcopy(getmetatable(o), seen))
	else -- number, string, boolean, etc
		no = o
	end
	return no
end




function serialize( fp, name, array, keep_functions )
	if type(fp) == "string" then
		keep_functions = array or false
		array = name
		name = fp
		fp = nil
	else
		keep_functions = keep_functions or false
	end

-- 	local tables_refs = {}

	local function _serialize_core( fwrite, name, value, tab, parent )
		if type(value) == "function" and not keep_functions then
			return false
		end

		for i = 1, tab do
			fwrite( "\t" )
		end

		fwrite( name .. " = " )
		if type(value) == "nil" or type(value) == "userdata" or type(value) == "lightuserdata" then
			fwrite( "nil" )
		elseif type(value) == "function" then
			fwrite( "nil --[[ function ]]" )
		elseif type(value) == "string" then
			fwrite( "\"" .. value .. "\"" )
		elseif type(value) == "number" or type(value) == "integer" then
			local str = "" .. value
			str = str:gsub( ",", "." )
			fwrite( str )
		elseif type(value) == "boolean" then
			if value then
				fwrite( "true" )
			else
				fwrite( "false" )
			end
		elseif type(value) == "table" then
-- 			if tables_refs[value] ~= nil then
-- 				fwrite( tables_refs[value] )
-- 			else
-- 				tables_refs[value] = parent .. name
				fwrite( "{\n" )
				for k, v in pairs(value) do
					if type(k) ~= "string" or ( k:sub(1, 2) ~= "__" and k ~= "class" ) then
						if _serialize_core( fwrite, k, v, tab + 1, name .. "." ) then
							fwrite( ",\n" )
						end
					end
				end
				for i = 1, tab do
					fwrite( "\t" )
				end
				fwrite( "}" )
-- 			end
		else
			fwrite( "nil --[[ ERROR : unknown value type '" .. type(value) .. "' ]]" )
		end
		return true
	end

	local retstr = ""
	local fwrite = nil

	if fp then
		fwrite = function( str ) fp:write( str ) end
	else
		fwrite = function( str ) retstr = retstr .. str end
	end

	_serialize_core( fwrite, name, array, 0, "" )

	fwrite( "\n" )

	return retstr
end

table.save = function( fp, name, t )
	serialize( fp, name, t, false )
end




function length2(v)
	return math.sqrt(v.x * v.x + v.y * v.y)
end

function distance2(v1, v2)
	return math.sqrt((v2.x - v1.x) * (v2.x - v1.x) + (v2.y - v1.y) * (v2.y - v1.y))
end

function normalize2(v)
	local v2 = { x = 0.0, y = 0.0 }
	local l = math.sqrt(v.x * v.x + v.y * v.y)
	if l > 0.00001 then
		v2.x = v.x / l
		v2.y = v.y / l
	end
	return v2
end

function collide(x1, y1, x2, y2, dist)
	local d = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
	return d <= dist
end


-- dofile("gelua/ui.Button.lua")
-- dofile("gelua/ui.InputText.lua")
-- 
-- dofile("gelua/Page.lua")
-- dofile("gelua/BigMenu.lua")
-- dofile("gelua/Menu.lua")
