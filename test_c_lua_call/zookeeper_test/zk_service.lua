local skynet = require "skynet"
require "skynet.manager"
local coroutine = require "skynet.coroutine"

print("ddddddd")
local zk_client = require("zk_async_client")
print("ddddddde")

local zk_host = skynet.getenv("zk_host")
local zk_timeout = tonumber(skynet.getenv("zk_timeout"))

local service = nil

local ZK_Service = {}

function ZK_Service.new()
    local data = {}
    data.zkhandle = nil
    return setmetatable(data, { __index = ZK_Service })
end

function ZK_Service:watcher(type, state, path)
    print("### lua watcher, type=" .. type .. " state=" .. state .. " path=" .. path);
end

local function watcher(type, state, path)
    service:watcher(type, state, path)
end

function ZK_Service:startup()
    print("ZK_Service startup! ")
    self.zkhandle = zk_client.zookeeper_init(zk_host, watcher, zk_timeout, 0, nil, 0)

    zk_client.acreate(self.zkhandle, "server", "", 0)
end

service = ZK_Service.new()

skynet.start(function()
    print("Test service start!")
    service:startup()
end)
