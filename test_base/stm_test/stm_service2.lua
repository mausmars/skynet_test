local skynet = require "skynet"

local Service = {}

function Service.new()
    local data = {}
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service2 startup!")
end

function Service:shutdown()
    print("Service2 shutdown!")
end

function Service:test1()
    --print("Service2 test1!")
    local ret = skynet.call(".stm_service1", "lua", "test1")
    return ret
end

function Service:gc()
    print("Service2 gc!")
    skynet.fork(function()
        while true do
            skynet.sleep(100 * 5)
            collectgarbage "collect"

            print("Service2 gc ", self:time2date())
        end
    end)
end

function Service:time2date()
    local ct = math.floor(skynet.time())
    return os.date("%Y-%m-%d %H:%M:%S", ct)
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

    --service:gc()
end)