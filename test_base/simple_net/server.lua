--引入框架
local skynet = require "skynet"
local socket = require "skynet.socket"

local function accept(id, addr)
    print("accept connect from addr: " .. addr .. " id: " .. id)
    socket.start(id)
    while true do
        local msg = socket.read(id)
        if msg then
            print(msg)
            socket.write(id, "msg from server")
        else
            socket.close(id)
            return
        end
    end
end

--service 实现这个方法
skynet.start(function()
    local listen_id = socket.listen("0.0.0.0", 8888)
    socket.start(listen_id, accept)
end)