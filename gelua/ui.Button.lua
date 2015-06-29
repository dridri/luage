Button = class("Button")

function Button:init(str, cb)
	self.text = str
	self.cb = cb
	self.visible = true
	self.focused = false
end

function Button:fullText()
	return self.text
end

function Button:render(font)
	local f = math.floor
	local fnt = font or screen.font[FONT_SIZE_NORMAL]
	local color = fnt.color
	local w, h = fnt:measureString(self.text)
	if self.focused then
		color = self.focus_color or color
	end
	screen.defaultShader:use()
	fnt:print(f(self.textx * screen.width), f(self.texty * screen.height), self.text, color)
end
