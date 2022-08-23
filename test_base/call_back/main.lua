local skynet = require "skynet"
require "skynet.manager"

local service_count = tonumber(skynet.getenv("service_count"))

skynet.start(function()
    print("Test start!")
    --skynet.newservice("debug_console", 8000)
    for i = 1, service_count do
        local sender_service = skynet.newservice("call_back_service")
        skynet.name(".call_back_service_" .. i, sender_service)
    end
    skynet.exit()
end)
