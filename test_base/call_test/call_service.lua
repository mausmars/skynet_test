local skynet = require "skynet"

local Service = {}

function Service.new()
    local data = {}
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service startup!")
end

function Service:shutdown()
    print("Service shutdown!")
end

-- sleep
function Service:test1()
    print("Service test1 sleep! 1")
    skynet.sleep(1000)
    print("Service test1 sleep! 2")
    return 1
end

-- call
function Service:test2()
    print("Service test2 call! 1")
    local ret = skynet.call(".call_service2", "lua", "test1")
    print("Service test2 call! 2")
    return ret
end

function Service:read_file()
    for line in io.lines("test_base/call_test/test.txt") do
        --print(line)
    end
end

-- 执行io
function Service:test3()
    print("Service test3 io! 1")
    --self:read_file()
    skynet.fork(function()
        self:read_file()
    end)
    print("Service test3 io! 2")
    return 1
end

-- empty
function Service:test4()
    print("Service test4 empty! 1")

    print("Service test4 empty! 2")
    return 1
end

-- #################################
local service = Service.new()

local CMD = {}

function CMD.exit()
    service:shutdown()
end

function CMD.test1()
    return service:test1()
end

function CMD.test2()
    return service:test2()
end

function CMD.test3()
    return service:test3()
end

function CMD.test4()
    return service:test4()
end

skynet.start(function()
    service:startup()

    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[tostring(cmd)]
        if f then
            local ret = table.pack(f(...))
            if session ~= 0 then
                skynet.ret(skynet.pack(table.unpack(ret)))
            end
        else
            print("unknown command %s", tostring(cmd))
        end
    end)
end)