net.Socket = class("net.Socket")

function net.Socket:init(server, port)
	if server == nil or port == nil or port == 0 or type(server) ~= "string" then
		error("net.Socket:init: Argument error")
	end
	self.connected = false
	self.server = server
	self.port = port
	self.sock = geSocket.new(server, port)
end

function net.Socket:connect()
	if self.sock:connect() == 0 then
		self.connected = true
	end
end

function net.Socket:send(buf)
	if buf ~= nil and type(buf) == "table" then
		self.sock:send(buf, #buf)
	end
end

function net.Socket:available()
	return self.sock:available()
end

function net.Socket:receive()
	return self.sock:receive()
end
