local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "skynet.manager"

skynet.start(function()
    local service = skynet.newservice("read_service")
    skynet.name(".read_service", service)

    skynet.fork(function()
        local ret = skynet.call(".read_service", "lua", "read_file")
    end)
end)