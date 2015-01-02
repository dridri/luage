-- This is a sample file
-- All coordinates are in range [0.0 - 1.0], no pixels involved

dofile("gelua/ge.lua")

MyPage = inheritsFrom(Page)
myPage = MyPage:create()

setup = function()
	screen.setFont(FONT_SIZE_NORMAL, "C:/Windows/Fonts/Arial.ttf", 1.0)
	screen.page = myPage
	screen.spage = "myPage"
end

-- Called once
function MyPage:setup()
	self.plot_radius = 0.01
end

-- Called each time this page is displayed
function MyPage:gotfocus()
	self.plots = {}
end

-- Called each time this page is hidden
function MyPage:lostfocus()
end

function MyPage:click(x, y, strenght, t)
	local plot = {}
	plot.x = x
	plot.y = y
	plot.text = "x"
	plot.t = t
	table.insert(self.plots, 1, plot)
end

-- Called everyframe - t is time, dt is delta since last call, both in seconds
function MyPage:update(t, dt)
	for i, plot in pairs(self.plots) do
		plot.x = plot.x + math.cos((t - plot.t) * 10.0) * self.plot_radius / screen.hratio
		plot.y = plot.y + math.sin((t - plot.t) * 10.0) * self.plot_radius / screen.vratio
	end
end

-- Called everyframe
function MyPage:draw()
	for i, plot in pairs(self.plots) do
		screen.print(plot.x, plot.y, plot.text)
	end
end

