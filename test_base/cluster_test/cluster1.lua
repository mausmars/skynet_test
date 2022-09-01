local skynet = require "skynet"
local cluster = require "skynet.cluster"
local snax = require "skynet.snax"

skynet.start(function()
    print("cluster1 start")
    cluster.reload {
        db1 = "127.0.0.1:2528",
        db2 = "127.0.0.1:2529",
    }

    local sdb = skynet.newservice("simpledb")
    -- register name "sdb" for simpledb, you can use cluster.query() later.
    -- See cluster2.lua
    cluster.register("sdb", sdb)        -- 将服务注册到云上 使用 @sdb


    print("set a= foobar")
    skynet.call(sdb, "lua", "SET", "a", "foobar")
    print("set b= foobar2")
    skynet.call(sdb, "lua", "SET", "b", "foobar2")
    print("get a= " .. skynet.call(sdb, "lua", "GET", "a"))
    print("get b= " .. skynet.call(sdb, "lua", "GET", "b"))

    -- node@servcie
    -- db1@sdb
    cluster.open("db1")     -- 开启节点
    cluster.open("db2")     -- 开启节点

    -- unique snax service
    --snax.uniqueservice "pingserver"
end)
