SpinBox = class("SpinBox")

function SpinBox:init(str, default, min, max, cb)
	self.label = str
	self.value = default
	self.min = min
	self.max = max
	self.cb = cb
	self.visible = true
	self.focused = false
	self.img_up = nil
	self.img_down = nil
end

function SpinBox:setup()
	self.img_up.w = self.img_up.width * screen.size / 1024
	self.img_up.h = self.img_up.height * screen.size / 1024
	self.img_down.w = self.img_down.width * screen.size / 1024
	self.img_down.h = self.img_down.height * screen.size / 1024

	self.y = self.y - self.img_up.height / screen.height
	self.h = self.h + 1.0 * self.img_up.height / screen.height
end

function SpinBox:fullText()
	return self.label .. " : " .. self.value
end

function SpinBox:render(font)
	local text = self.label .. " : " .. self.value
	self.font = font or screen.font[FONT_SIZE_NORMAL]
	local w, h = self.font:measureString(text)
	screen.defaultShader:use()
	self.font:print(self.textx * screen.width, self.texty * screen.height, text)
	if self.focused then
		local w, h = self.font:measureString(self.label .. " : ")
		local x = math.floor(self.textx * screen.width + w) - h * 0.05
		local y = math.floor(self.texty * screen.height)
-- 		local size = 1.0
		if self.img_up then
			geImage.blitStretched(x, y - h * 0.25, self.img_up.w, self.img_up.h, self.img_up, 0, 0, self.img_up.width, self.img_up.height, 0)
		end
		if self.img_down then
			geImage.blitStretched(x, y + h * 0.75, self.img_down.w, self.img_down.h, self.img_down, 0, 0, self.img_down.width, self.img_down.height, 0)
		end
	end
end

function SpinBox:click(mx, my)
	mx = mx * screen.width
	my = my * screen.height
	local w, h = self.font:measureString(self.label .. " : ")
	local x = math.floor(self.textx * screen.width + w) - h * 0.1
	local y = math.floor(self.texty * screen.height)
	if mx >= x and mx <= x + self.img_up.w * 1.5 then
		if my >= y - h * 0.25 and my <= y - h * 0.25 + self.img_up.h and self.value < self.max then
			self.value = self.value + 1
		end
		if my >= y + h * 0.75 and my <= y + h * 0.75 + self.img_down.h and self.value > self.min then
			self.value = self.value - 1
		end
	end
end
