local skynet = require("skynet")

local BusinessService = {}

function BusinessService.new()
    local data = {}
    data.num = 0
    return setmetatable(data, { __index = BusinessService })
end

function BusinessService:startup()
    print("BusinessService startup!")
    self:work()
    self:io_work_a()
    self:io_work_b()
end

function BusinessService:work()
    local service = self
    skynet.fork(function()
        while true do
            service.num = service.num + 1
            skynet.sleep(1)
        end
    end)
end

function BusinessService:io_work_a()
    skynet.fork(function()
        local i = 1
        while true do
            skynet.send(".io_service", "lua", "async_read_io_a", i)
            if i % 3 == 0 then
                skynet.sleep(10)
            end
            i = i + 1
        end
    end)

end

function BusinessService:io_work_b()
    skynet.fork(function()
        local i = 1
        while true do
            skynet.send(".io_service", "lua", "async_read_io_b", i)
            if i % 3 == 0 then
                skynet.sleep(10)
            end
            i = i + 1
        end
    end)

end

function BusinessService:shutdown()
    print("BusinessService shutdown!")
    --关闭当前服务
    skynet.exit()
end

local service = BusinessService.new()

local CMD = {}

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










