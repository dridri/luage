InputText = class("InputText")

function InputText:init(str, def, cb)
	self.label = str
	self.text = def
	self.cb = cb
	self.visible = true
end

function InputText:fullText()
	return self.label .. " : " .. self.text
end

function InputText:render(font)
	local text = self.label .. " : " .. self.text
	if font ~= nil then
		local w, h = font:measureString(text)
		screen.defaultShader:use()
		font:print(self.textx * screen.width, self.texty * screen.height, text)
	else
		local w, h = screen.font[FONT_SIZE_NORMAL]:measureString(text)
		screen.defaultShader:use()
		screen.font[FONT_SIZE_NORMAL]:print(self.textx * screen.width, self.texty * screen.height, text)
	end
end
