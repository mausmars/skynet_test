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
    print("Service2 test1 sleep! 1")
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