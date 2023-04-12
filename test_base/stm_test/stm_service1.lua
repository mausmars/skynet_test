local skynet = require "skynet"
local stm = require "skynet.stm"

local gc_count = 0

local function data_gc(self)
    --print("data_gc", self)
    gc_count = gc_count + 1
end

local Data = {}

function Data.new(name, age)
    local data = {}
    data.name = name
    data.age = age
    data.members = {}
    return setmetatable(data, { __index = Data, __gc = data_gc })
end

local Service = {}

function Service.new()
    local data = {}
    data.stm_objs = {}
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service1 startup!")
    -- 停止gc
    --collectgarbage("stop")
    print("Service1 gc state !", collectgarbage("isrunning"))
end

function Service:shutdown()
    print("Service1 shutdown!")
end

function Service:create_data()
    local data = Data.new("test", 10)
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
    --self.stm_objs[pointer] = stm_obj
    return pointer
end

function Service:gc()
    print("Service1 gc!")
    skynet.fork(function()
        while true do
            skynet.sleep(100 * 5)
            collectgarbage("collect")
            print("Service1 gc ", self:time2date())
        end
    end)
end

function Service:print_gc_count()
    print("Service1 print_gc_count!")
    skynet.fork(function()
        while true do
            print("Service1 gc_count=", gc_count, collectgarbage("count"), self:time2date())
            skynet.sleep(1)
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

    service:print_gc_count()

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