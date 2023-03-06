local skynet = require "skynet"

local redis_service = require("redis_service")

local redis_host = skynet.getenv("redis_host")
local redis_port = skynet.getenv("redis_port")
local redis_auth = skynet.getenv("redis_auth")

skynet.start(function()
    print("redis1 test start!")
    local redisService = redis_service.new(redis_host, redis_port, redis_auth, 0)
    redisService:start()

    local channelName1 = "toplist_update"
    redisService:subscribe(channelName1)
    local channelName2 = "test_channel"
    redisService:subscribe(channelName2)

    redisService:publish(channelName1, "redis2 BATTLE@10001")
    redisService:publish(channelName2, "redis2 test_channel_msg")
end)