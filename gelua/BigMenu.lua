BigMenu = inheritsFrom( Page )

function BigMenu:preinit()
	self.buttons = {}

	self:setup()

	local y = screen.height / 2 - (#self.buttons * self.font.size * 2) / 2
	local bigger = { 0, 0 }

	for k,v in pairs(self.buttons) do
		w, h = self.font:measureString(v.text)
		v.y = y / screen.height
		bigger[1] = math.max(bigger[1], w)
		bigger[2] = math.max(bigger[2], h)
		y = y + self.font.size * 2
		v.textx = (screen.width / 2 - w / 2) / screen.width
		v.texty = v.y
	end

	local x = 0.5 - bigger[1] / 2 / screen.width

	for k,v in pairs(self.buttons) do
		v.x = x
		v.w = bigger[1] / screen.width
		v.h = bigger[2] / screen.height
	end
end

function BigMenu:click(x, y, force)
	local i = 0
	for k,v in pairs(self.buttons) do
		if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
			v.cb()
			break
		end
		i = i + 1
	end
end

function BigMenu:run()
	self:draw()
	for k,v in pairs(self.buttons) do
		v:render(self.font)
	end
end
