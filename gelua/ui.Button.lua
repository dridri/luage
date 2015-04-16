Button = class("Button")

function Button:init(str, cb)
	self.text = str
	self.cb = cb
	self.visible = true
end

function Button:fullText()
	return self.text
end

function Button:render(font)
	local f = math.floor
	if font ~= nil then
		local w, h = font:measureString(self.text)
		screen.defaultShader:use()
		font:print(f(self.textx * screen.width), f(self.texty * screen.height), self.text)
	else
		local w, h = screen.font[FONT_SIZE_NORMAL]:measureString(self.text)
		screen.defaultShader:use()
		screen.font[FONT_SIZE_NORMAL]:print(f(self.textx * screen.width), f(self.texty * screen.height), self.text)
	end
end
