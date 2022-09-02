local socket = require("socket")

local function print_addr(hostname)
    local ip, resolved = socket.dns.toip(hostname)
    for k, v in ipairs(resolved.ip) do
        print(v)
    end
end

local function test()
    print(print_addr('localhost'))
    print("---------------")
    print(print_addr(socket.dns.gethostname()))
end

test()
