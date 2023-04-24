local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "skynet.manager"

skynet.start(function()
    for i = 1, 10 do
        local service = skynet.newservice("write_servcie")
        skynet.name(".write_servcie_" .. i, service)
    end

    for i = 1, 10 do
        skynet.fork(function()
            skynet.call(".write_servcie_" .. i, "lua", "write_file", i)
        end)
    end
end)