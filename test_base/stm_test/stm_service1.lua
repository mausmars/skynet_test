local skynet = require "skynet"
local stm = require "skynet.stm"

local Service = {}

function Service.new()
    local data = {}
    data.stm_objs = {}
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service1 startup!")
end

function Service:shutdown()
    print("Service1 shutdown!")
end

function Service:create_data()
    local data = {
        name = "test",
        age = 10,
        members = {},
    }
    for i = 1, 1000 do
        table.insert(data.members, { name = "member_" .. tostring(i), age = i })
    end
    return data
end

function Service:test1()
    --print("Service1 test1!")
    local data = self:create_data()
    local stm_obj = stm.new(skynet.pack(data))
    local pointer = stm.copy(stm_obj)

    self.stm_objs[pointer] = stm_obj

    return pointer
end

function Service:gc()
    print("Service1 gc!")
    skynet.fork(function()
        while true do
            skynet.sleep(100 * 5)
            collectgarbage "collect"
            print("Service1 gc ", self:time2date())
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