local skynet = require "skynet"

local redis_service = require("redis_service")

skynet.start(function()
    print("redis1 test start!")
    local redisService = redis_service.new('127.0.0.1', 10001, 'Windward_2021@redis', 0)
    redisService:start()

    local channelName = "channel_test@1"
    redisService:subscribe(channelName)
    redisService:publish(channelName, "hello1")
end)