local socket = require "socket"

local function test()
    local t = socket.gettime()

    local a = 0
    for i = 1, 10000 do
        a = a + 1
    end
    t = socket.gettime() - t
    print("t=", t * 1000 * 1000 * 1000, "ns")
end

test()