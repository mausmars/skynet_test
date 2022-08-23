local skynet = require "skynet"
require "skynet.manager"
local coroutine = require "skynet.coroutine"

local zk_client = require("zk_client")

local zk_host = skynet.getenv("zk_host")
local zk_timeout = tonumber(skynet.getenv("zk_timeout"))

local ZK_Service = {}

function ZK_Service.new()
    local data = {}
    return setmetatable(data, { __index = ZK_Service })
end

local function watcher(type, state, path)
    print("### lua watcher, type=" .. type .. " state=" .. state .. " path=" .. path);
end

function ZK_Service:startup()
    print("ZK_Service startup! ")
    --zk_client.register_watch(watcher)
    local zkhandle = zk_client.zookeeper_init(zk_host, watcher, zk_timeout, 0, nil, 0)

    os.execute("sleep " .. 2)

end

local service = ZK_Service.new()

skynet.start(function()
    print("Test service start!")
    service:startup()
end)
