local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "skynet.manager"

local function test1()
    skynet.fork(function()
        local ret = skynet.call(".call_service", "lua", "test1")
        print("test1 ", ret)
    end)
end

local function test2()
    skynet.fork(function()
        local ret = skynet.call(".call_service", "lua", "test2")
        print("test2 ", ret)
    end)
end

local function test3()
    skynet.fork(function()
        local ret = skynet.call(".call_service", "lua", "test3")
        print("test3 ", ret)
    end)
end

local function test4()
    skynet.fork(function()
        local ret = skynet.call(".call_service", "lua", "test4")
        print("test4 ", ret)
    end)
end

skynet.start(function()
    local service = skynet.newservice("call_service")
    skynet.name(".call_service", service)

    local service = skynet.newservice("call_service2")
    skynet.name(".call_service2", service)

    test1()
    test2()
    test3()
    test4()
end)
