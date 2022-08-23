local skynet = require "skynet"
local coroutine = require "skynet.coroutine"

local task1 = function()
    for i = 1, 3 do
        print("task1")
        skynet.sleep(100)
    end
end

local task2 = function()
    for i = 1, 3 do
        print("task2")
        skynet.sleep(100)
    end
end

local function test1()
    print("test start")

    --非抢占试，需要手动切换
    local co1 = coroutine.create(task1)
    local co2 = coroutine.create(task2)
    coroutine.resume(co1)
    coroutine.resume(co2)

    print("test end")
end

local function test2()
    print("test start")

    --交替执行
    skynet.fork(task1)
    skynet.fork(task2)

    print("test end")
end

skynet.start(function()
    --test1()
    test2()
end)