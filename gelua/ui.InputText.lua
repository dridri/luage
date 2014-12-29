InputText = {}
InputText_mt = { __index = InputText }

function InputText:create(str, def, cb)
	local new_inst = {}
	setmetatable( new_inst, InputText_mt )
	new_inst.label = str
	new_inst.text = def
	new_inst.cb = cb
	return new_inst
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
