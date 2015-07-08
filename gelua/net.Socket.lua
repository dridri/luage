net = net or {}

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
	if ret == 0 then
		self.connected = true
	end
end

function net.Socket:close()
	return self.sock:close()
end

function net.Socket:send( data )
	local str = ""
	if data ~= nil then
		str = serialize( "", data )
	end
	return self.sock:send( str )
end

function net.Socket:rawsend( data )
	if type(data) == "string" then
		return self.sock:send( data )
	else
		return self.sock:send( data, #data )
	end
end

function net.Socket:available()
	return self.sock:available()
end

function net.Socket:receive()
	return self.sock:receive()
end
