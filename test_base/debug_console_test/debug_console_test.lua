local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("debug_console", 4444)
end)
