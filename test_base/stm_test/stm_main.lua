local skynet = require "skynet"
require "skynet.manager"

local function test1(test_context)
    skynet.fork(function()
        print("test1 start! id=" .. test_context.id .. " total_times=" .. test_context.total_times)
        for i = 1, test_context.total_times do
            skynet.call(".stm_service3_" .. test_context.id, "lua", "test1", test_context.id)
            test_context.times = test_context.times + 1
        end
        print("test1 over! id=" .. test_context.id)
        test_context.state = 0
    end)

    skynet.fork(function()
        while true do
            if test_context.state <= 0 then
                break
            end
            skynet.sleep(10 * 100)
            print("test id=" .. test_context.id .. " times=" .. test_context.times)
        end
    end)
end

local function test2(test_context)
    skynet.fork(function()
        print("test2 start! id=" .. test_context.id .. " total_times=" .. test_context.total_times)
        for i = 1, test_context.total_times do
            skynet.call(".stm_service3_" .. test_context.id, "lua", "test2", test_context.id)
            test_context.times = test_context.times + 1
        end
        print("test2 over! id=" .. test_context.id)
        test_context.state = 0
    end)

    skynet.fork(function()
        while true do
            if test_context.state <= 0 then
                break
            end
            skynet.sleep(10 * 100)
            print("test id=" .. test_context.id .. " times=" .. test_context.times)
        end
    end)
end

local function create_context(id)
    local test_context = {
        id = id, --测试id
        times = 0, --执行次数
        state = 1, --运行状态 1运行 0停止
        total_times = 1 * 10000, --调用总次数
    }
    return test_context
end

skynet.start(function()
    local stm_service1 = skynet.newservice("stm_service1")
    skynet.name(".stm_service1", stm_service1)

    local client_count = 5      --并行service

    for i = 1, client_count do
        local stm_service2 = skynet.newservice("stm_service2")
        skynet.name(".stm_service2_" .. i, stm_service2)

        local stm_service3 = skynet.newservice("stm_service3")
        skynet.name(".stm_service3_" .. i, stm_service3)
    end

    -- 过多个2 service 调用共享数据
    --for id = 1, client_count do
    --    local test_context = create_context(id)
    --    test1(test_context)
    --end

    -- 直接一个service 调用共享数据
    for id = 1, client_count do
        local test_context = create_context(id)
        test2(test_context)
    end
end)
