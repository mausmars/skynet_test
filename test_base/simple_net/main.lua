local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("server") -- 启动服务：server
    skynet.exit()
end)