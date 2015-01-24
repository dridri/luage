Page = class("Page")

function Page:init()
	self.initialized = false
end

function Page:baseinit()
-- 	geDebugPrint(0, "Page:baseinit()")
	if self.initialized == false then
		self:preinit()
	end
	self.initialized = true

	self:gotfocus()
end

function Page:preinit()
-- 	geDebugPrint(0, "Page:preinit()")
	self:setup()
end

function Page:setup()
-- 	geDebugPrint(0, "Page:setup()")
end

function Page:gotfocus()
-- 	geDebugPrint(0, "Page:gotfocus()")
end

function Page:lostfocus()
-- 	geDebugPrint(1, "Page:lostfocus()")
end

function Page:update(t, dt)
-- 	geDebugPrint(0, "Page:update()")
end

function Page:draw()
-- 	geDebugPrint(0, "Page:draw()")
end

function Page:run()
-- 	geDebugPrint(0, "Page:run()")
	self:draw()
end

function Page:click(x, y, force)
-- 	geDebugPrint(0, "Page:click()")
end

function Page:touch(x, y, force)
-- 	geDebugPrint(0, "Page:touch()")
end




-- Page = {}
-- Page_mt = { __index = Page }
-- 
-- function Page:create()
-- 	local new_inst = {}
-- 	setmetatable( new_inst, Page_mt )
-- 	new_inst:constructor()
-- 	return new_inst
-- end
-- 
-- function Page:constructor()
-- 	self.initialized = false
-- end
-- 
-- function Page:baseinit()
-- -- 	geDebugPrint(0, "Page:baseinit()")
-- 	if self.initialized == false then
-- 		self:preinit()
-- 	end
-- 	self.initialized = true
-- 
-- 	self:gotfocus()
-- end
-- 
-- function Page:preinit()
-- -- 	geDebugPrint(0, "Page:preinit()")
-- 	self:setup()
-- end
-- 
-- function Page:setup()
-- -- 	geDebugPrint(0, "Page:setup()")
-- end
-- 
-- function Page:gotfocus()
-- -- 	geDebugPrint(0, "Page:gotfocus()")
-- end
-- 
-- function Page:lostfocus()
-- -- 	geDebugPrint(1, "Page:lostfocus()")
-- end
-- 
-- function Page:update(t, dt)
-- -- 	geDebugPrint(0, "Page:update()")
-- end
-- 
-- function Page:draw()
-- -- 	geDebugPrint(0, "Page:draw()")
-- end
-- 
-- function Page:run()
-- -- 	geDebugPrint(0, "Page:run()")
-- 	self:draw()
-- end
-- 
-- function Page:click(x, y, force)
-- -- 	geDebugPrint(0, "Page:click()")
-- end
-- 
-- function Page:touch(x, y, force)
-- -- 	geDebugPrint(0, "Page:touch()")
-- end
