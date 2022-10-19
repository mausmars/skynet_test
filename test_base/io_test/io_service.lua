local skynet = require("skynet")

local read_file = skynet.getenv("read_file")

local IOService = {}

function IOService.new()
    local data = {}
    return setmetatable(data, { __index = IOService })
end

function IOService:startup()
    print("IOService startup!")
end

function IOService:shutdown()
    print("IOService shutdown!")
    --关闭当前服务
    skynet.exit()
end

function IOService:_read_io_a(i)
    print("-----------------------a " .. i)
    print("_read_io_a start " .. i)
    local input = io.open(read_file, "r")
    print("io.open_a " .. i)
    local content = input:read("*a")
    print("read_a " .. i)
    input:close()
    print("_read_io_a over " .. i)
end

function IOService:_read_io_b(i)
    print("-----------------------b " .. i)
    print("_read_io_b start " .. i)
    --local input = io.open(read_file, "r")
    print("io.open_b " .. i)
    --local content = input:read("*a")
    print("read_b " .. i)
    --input:close()
    print("_read_io_b over " .. i)
end

function IOService:async_read_io_a(i)
    local service = self
    skynet.fork(function()
        service:_read_io_a(i)
    end)
end

function IOService:async_read_io_b(i)
    local service = self
    skynet.fork(function()
        service:_read_io_b(i)
    end)
end

local service = IOService.new()

local CMD = {}

function CMD.async_read_io_a(i)
    return service:async_read_io_a(i)
end

function CMD.async_read_io_b(i)
    return service:async_read_io_b(i)
end

skynet.start(function()
    service:startup()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[tostring(cmd)]
        if f then
            local ret = f(...)
            if session ~= 0 then
                skynet.ret(skynet.pack(ret))
            end
        else
            print("unknown command" .. tostring(cmd))
        end
    end)
end)










