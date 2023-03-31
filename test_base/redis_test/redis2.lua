local skynet = require "skynet"

local redis_service = require("redis_service")

skynet.start(function()
    print("redis2 test start!")
    local redisService = redis_service.new('127.0.0.1', 10001, 'Windward_2021@redis', 0, 3)
    redisService:start()

    -- 测试注册频道
    print("test subscribe!")
    local channelName_template = "channel_test@%d"
    for i = 1, 5 do
        local channelName = string.format(channelName_template, i)
        redisService:subscribe(channelName)
    end

    -- 广播消息
    print("test publish! 1")
    redisService:publish("channel_test@1", "hello1")
    redisService:publish("channel_test@2", "hello2")

    print("test sleep!")
    skynet.sleep(500)

    redisService:unsubscribe("channel_test@1")

    print("test publish! 2")
    redisService:publish("channel_test@1", "hello1")
    redisService:publish("channel_test@2", "hello2")

    print("test sleep!")
    skynet.sleep(500)

    -- 测试注销频道
    print("test unsubscribe!")
    for i = 1, 1000 do
        local channelName = channelName_template + tostring(i)
        redisService:unsubscribe(channelName)
    end

    redisService:shutdown()
    print("redis2 test over!")
end)