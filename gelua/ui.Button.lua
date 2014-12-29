Button = {}
Button_mt = { __index = Button }

function Button:create(str, cb)
	local new_inst = {}
	setmetatable( new_inst, Button_mt )
	new_inst.text = str
	new_inst.cb = cb
	return new_inst
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
