local skynet = require "skynet"
require "skynet.manager"

local service_count = tonumber(skynet.getenv("service_count"))

skynet.start(function()
    print("Test start!")
    --skynet.newservice("debug_console", 8000)
    for i = 1, service_count do
        local service = skynet.newservice("zk_service")
        skynet.name(".zk_service" .. i, service)
    end
    skynet.exit()
end)
