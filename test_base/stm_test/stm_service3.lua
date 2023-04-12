local skynet = require "skynet"
local stm = require "skynet.stm"

local Service = {}

function Service.new()
    local data = {}
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service3 startup!")
end

function Service:shutdown()
    print("Service3 shutdown!")
end

function Service:test1(id)
    --LOG_DEBUG("Service3 test1!")
    local ret = skynet.call(".stm_service2_" .. id, "lua", "test1")
    local obj = self:rank_data_unpack(ret)
    if obj ~= nil then
        print("Service3 id=" .. id .. " name=" .. obj.name)
    else
        print("Service3 obj=nil id=" .. id)
    end
end

function Service:test2(id)
    local ret = skynet.call(".stm_service1", "lua", "test1")
    local obj = self:rank_data_unpack(ret)
    if obj ~= nil then
        print("Service3 id=" .. id .. " name=" .. obj.name)
    else
        print("Service3 obj=nil id=" .. id)
    end
end

function Service:rank_data_unpack(t)
    local stm_obj = stm.newcopy(t)
    --LOG_DEBUG("Service3 rank_data_unpack t=%s", t)
    local ok, data = stm_obj(function(msg, sz)
        return skynet.unpack(msg, sz)
    end)
    --LOG_DEBUG("Service3 rank_data_unpack, ok=%s", ok)
    if not ok or not data then
        print("rank_data_unpack, ok=" .. tostring(ok) .. " data=", data, self:time2date())
        return nil
    end
    return data
end

function Service:gc()
    print("Service3 gc!")
    skynet.fork(function()
        while true do
            skynet.sleep(100 * 5)
            collectgarbage "collect"
            print("Service3 gc ", self:time2date())
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

function CMD.test1(id)
    return service:test1(id)
end

function CMD.test2(id)
    return service:test2(id)
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