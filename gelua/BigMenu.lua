BigMenu = Page:extend("BigMenu")

function BigMenu:preinit()
	self.buttons = {}
	self.currentIndex = -1

	self:setup()
	if self.focus_color == nil then
		self.focus_color = self.font.color
	end
	for k,v in pairs(self.buttons) do
		v.focus_color = self.focus_color
	end

	local y = screen.height / 2 - (#self.buttons * self.font.size * 2) / 2
	local bigger = { 0, 0 }

	for k,v in pairs(self.buttons) do
		local w, h = self.font:measureString(v.text)
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
			v:cb()
			break
		end
		i = i + 1
	end
end

function BigMenu:setController(js)
	if type(js.toggles) == "nil" then
		self.controllers = js
	else
		self.controllers = {}
		self.controllers[0] = js
	end
end

function BigMenu:_control()
	if self.controllers ~= nil then
		for k,js in pairs(self.controllers) do
			js:read()
			if js.toggles[13] ~= 0 and self.currentIndex > 1 then
				self.buttons[self.currentIndex].focused = false
				self.currentIndex = self.currentIndex - 1
				self.buttons[self.currentIndex].focused = true
			end
			if js.toggles[14] ~= 0 and self.currentIndex < #self.buttons then
				self.buttons[self.currentIndex].focused = false
				self.currentIndex = self.currentIndex + 1
				self.buttons[self.currentIndex].focused = true
			end
			if js.toggles[0] ~= 0 then
				self.buttons[self.currentIndex]:cb()
				self.buttons[self.currentIndex].focused = false
				self.currentIndex = -1
				break
			end
		end
	end
end

function BigMenu:run()
	self:_control()
	self:draw()
	for k,v in pairs(self.buttons) do
		v:render(self.font)
	end
end
