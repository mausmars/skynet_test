local skynet = require "skynet"
local cluster = require "skynet.cluster"

skynet.start(function()
    print("cluster2 start")
    local proxy = cluster.proxy("db1", "@sdb")
    print("create node proxy " .. proxy)

    --local proxy = cluster.proxy "db1@sdb"
    local largekey = string.rep("X", 128 * 1024)
    local largevalue = string.rep("R", 100 * 1024)
    -- skynet.call (云代理...
    skynet.call(proxy, "lua", "SET", largekey, largevalue)

    local v = skynet.call(proxy, "lua", "GET", largekey)
    if largevalue == v then
        print("largevalue == v")
    end

    --skynet.send(proxy, "lua", "PING", "proxy")

    skynet.fork(function()
        skynet.trace("cluster")
        -- cluster.call (node, @service...
        print(cluster.call("db1", "@sdb", "GET", "a"))
        print(cluster.call("db2", "@sdb", "GET", "b"))
        cluster.send("db2", "@sdb", "PING", "db2:longstring" .. largevalue)
    end)

    -- test snax service
    skynet.timeout(300, function()
        cluster.reload {
            db1 = false, -- db1 is down
            db3 = "127.0.0.1:2529"
        }
        print("111 ", pcall(cluster.call, "db1", "@sdb", "GET", "a"))    -- db is down
    end)

    -- db3 不存在，阻塞等待，3秒后reload db3 映射到节点db2上，获取到数据
    cluster.reload { __nowaiting = false }
    print("222 ", pcall(cluster.call, "db3", "@sdb", "GET", "a"))

    --local pingserver = cluster.snax("db3", "pingserver")
    --print(pingserver.req.ping "hello")
end)
