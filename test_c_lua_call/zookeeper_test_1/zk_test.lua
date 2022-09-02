package.cpath = "./createlib/?.so" --so搜寻路劲
local zk_client = require "zk_client" -- 对应luaopen_test中的myLualib

local function watcher(type, state, path)
    print("### lua watcher, type=" .. type .. " state=" .. state .. " path=" .. path);
end

local function test()
    print("--- test zk ---")

    local host = "localhost:2181"
    local timeout = 30000;

    zk_client.register_watch(watcher)

    local zkhandle = zk_client.zookeeper_init(host, timeout, 0, nil, 0)

    os.execute("sleep " .. 2)
end

test()

