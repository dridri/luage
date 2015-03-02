Runnable = class("Runnable")

function Runnable:init(name)
end

function Runnable:start()
	if self.thread == nil then
		self.thread = geThread.new("GE_LUA_THREAD", self.name .. ".entry")
	end
	print("name : " .. self.name)
	self.thread:start(self.name)
end

function Runnable:entry()
	print("IN ENTRY")
-- 	self.t = geGetTick()
-- 	self.dt = 0.0
	while true do
--		geSleep(1)
--		self.run(self.t, self.dt)
--		print("plop")
--		self.dt = geGetTick() - self.t
--		self.t = geGetTick()
	end
end
