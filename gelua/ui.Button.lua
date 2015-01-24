Button = class("Button")

function Button:init(str, cb)
	self.text = str
	self.cb = cb
end

function Button:fullText()
	return self.text
end

function Button:render(font)
	if font ~= nil then
		w, h = font:measureString(self.text)
		screen.defaultShader:use()
		font:print(self.textx * screen.width, self.texty * screen.height, self.text)
	else
		w, h = screen.font[FONT_SIZE_NORMAL]:measureString(self.text)
		screen.defaultShader:use()
		screen.font[FONT_SIZE_NORMAL]:print(self.textx * screen.width, self.texty * screen.height, self.text)
	end
end
