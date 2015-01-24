InputText = class("InputText")

function InputText:init(str, def, cb)
	self.label = str
	self.text = def
	self.cb = cb
end

function InputText:fullText()
	return self.label .. " : " .. self.text
end

function InputText:render(font)
	local text = self.label .. " : " .. self.text
	if font ~= nil then
		w, h = font:measureString(text)
		screen.defaultShader:use()
		font:print(self.textx * screen.width, self.texty * screen.height, text)
	else
		w, h = screen.font[FONT_SIZE_NORMAL]:measureString(text)
		screen.defaultShader:use()
		screen.font[FONT_SIZE_NORMAL]:print(self.textx * screen.width, self.texty * screen.height, text)
	end
end
