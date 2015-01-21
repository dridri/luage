sfx.Player = class("sfx.Player")

function sfx.Player:init( media )
	self.media = nil
	self.playing = false
	self.stopped = false
	self.volume = 100
	if media ~= nil then
		self:setMedia( media )
		self:play()
	end
end

function sfx.Player:setMedia( media )
	self.media = media
	if self.media ~= nil then
		-- TODO
	end
end

function sfx.Player:play()
	if self.media ~= nil then
		-- TODO
		self.stopped = false
		self.playing = true
	end
end

function sfx.Player:pause()
	if not self.stopped then
		self.playing = not self.playing
		if self.media ~= nil then
			-- TODO
		end
	end
end

function sfx.Player:stop()
	self.stopped = true
	self.playing = false
	if self.media ~= nil then
		-- TODO
	end
end
