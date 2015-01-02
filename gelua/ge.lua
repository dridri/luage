FONT_SIZE_NORMAL = 0
FONT_SIZE_SMALL = 1
FONT_SIZE_LARGE = 2

CENTER = -2147483647 + 1

DRAW_ADJUST = 1

ORIGIN_TOPLEFT = 0
ORIGIN_CENTER = 1


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


screen.init = function(w, h)
	screen.width = w
	screen.height = h
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
	pixels = screen.size / 20
	if sz == FONT_SIZE_SMALL then
		pixels = pixels * 0.75
	elseif sz == FONT_SIZE_LARGE then
		pixels = pixels * 1.25
	end
	screen.font[sz].size = pixels * factor
end

screen.draw = function(img, align, _x, _y)
	screen.shader:use()
	x = 0
	y = 0
	flags = 0
	size = 1.0
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
	if img.angle and img.angle ~= 0 then
		geImage.blitStretchedRotated(x, y, img:width() * size, img:height() * size, img, img.angle, 0, 0, img:width(), img:height(), flags)
	else
		geImage.blitStretched(x, y, img:width() * size, img:height() * size, img, 0, 0, img:width(), img:height(), flags)
	end
end

screen.print = function(x, y, str)
	screen.defaultShader:use()
	if x == CENTER then
		w, h = screen.font[FONT_SIZE_NORMAL]:measureString(str)
		x = 0.5 - w / 2 / screen.width
	end
	screen.font[FONT_SIZE_NORMAL]:print(x * screen.width, y * screen.height, str)
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




function inheritsFrom( baseClass )
	new_class = {}
	new_class_mt = { __index = new_class }
	setmetatable( new_class, { __index = baseClass } )

	function new_class:create()
		local new_inst = {}
		setmetatable( new_inst, new_class_mt )
		new_inst:constructor()
		return new_inst
	end

	return new_class
end

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




function serialize(v)
	if type(v) == "nil" or type(v) == "userdata" or type(v) == "lightuserdata" then
		return "nil"
	elseif type(v) == "number" or type(v) == "integer" or type(v) == "boolean" then
		return "" .. v
	elseif type(v) == "string" then
		return string.format("%q", v)
	else
		return "unknown type " .. type(v)
	end
end

table.save = function(fp, name, t)
	fp:write(name .. " = " .. "{}")
	for k, v in pairs(t) do
		local sk = ""
		if type(k) == "integer" then
			sk = "" .. k
		elseif type(k) == "string" then
			sk = string.format("%q", k)
		else
			sk = "unknown type " .. type(k)
		end
		if type(v) == "table" then
			table.save(fp, name .. "[" .. sk .. "]", v)
		else
			fp:write(name .. "[" .. sk .. "] = ")
		end
	end
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
	d = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
	return d <= dist
end


-- dofile("gelua/ui.Button.lua")
-- dofile("gelua/ui.InputText.lua")
-- 
-- dofile("gelua/Page.lua")
-- dofile("gelua/BigMenu.lua")
-- dofile("gelua/Menu.lua")
