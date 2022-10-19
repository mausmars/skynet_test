local skynet = require "skynet"
require "skynet.manager"

skynet.start(function()
    print("Test start!")
    --skynet.newservice("debug_console", 8000)

    local io_service = skynet.uniqueservice("io_service")
    skynet.name(".io_service", io_service)

    local business_service = skynet.uniqueservice("business_service")
    skynet.name(".business_service", business_service)

    skynet.exit()
end)
