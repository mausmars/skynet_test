local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local bson = require "bson"

local host, port, db_name, username, password = "127.0.0.1", 27017, "test1", "", ""
local host2, port2, db_name2, username2, password2 = "127.0.0.1", 27017, "test2", "", ""

if port then
    port = math.tointeger(port)
end

-- print(host, port, db_name, username, password)

local function _create_client()
    local c1 = { host = host, port = port,
                 username = username, password = password,
                 authdb = db_name }
    local c2 = { host = host2, port = port2,
                 username = username2, password = password2,
                 authdb = db_name2 }

    local conf = { rs = { c1, c2 } }

    return mongo.client(conf)
end

function test_auth()
    local ok, err, ret
    local c = mongo.client(
            {
                host = host, port = port,
            }
    )
    local db = c[db_name]
    db:auth(username, password)

    db.testcoll:dropIndex("*")
    db.testcoll:drop()

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1 });
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1 });
    assert(ok and ret and ret.n == 1, err)
end

function test_insert_without_index()
    local ok, err, ret
    local c = _create_client()
    local db = c[db_name]

    db.testcoll:dropIndex("*")
    db.testcoll:drop()

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1 });
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1 });
    assert(ok and ret and ret.n == 1, err)
end

function test_insert_with_index()
    local ok, err, ret
    local c = _create_client()
    local db = c[db_name]

    db.testcoll:dropIndex("*")
    db.testcoll:drop()

    db.testcoll:ensureIndex({ test_key = 1 }, { unique = true, name = "test_key_index" })

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1 })
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1 })
    assert(ok == false and string.find(err, "duplicate key error"))
end

function test_find_and_remove()
    local ok, err, ret
    local c = _create_client()
    local db = c[db_name]

    db.testcoll:dropIndex("*")
    db.testcoll:drop()

    db.testcoll:ensureIndex({ test_key = 1 }, { test_key2 = -1 }, { unique = true, name = "test_index" })

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1, test_key2 = 1 })
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1, test_key2 = 2 })
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 2, test_key2 = 3 })
    assert(ok and ret and ret.n == 1, err)

    ret = db.testcoll:findOne({ test_key2 = 1 })
    assert(ret and ret.test_key2 == 1, err)

    ret = db.testcoll:find({ test_key2 = { ['$gt'] = 0 } }):sort({ test_key = 1 }, { test_key2 = -1 }):skip(1):limit(1)
    assert(ret:count() == 3)
    assert(ret:count(true) == 1)
    if ret:hasNext() then
        ret = ret:next()
    end
    assert(ret and ret.test_key2 == 1)

    db.testcoll:delete({ test_key = 1 })
    db.testcoll:delete({ test_key = 2 })

    ret = db.testcoll:findOne({ test_key = 1 })
    assert(ret == nil)
end

function test_runcommand()
    local ok, err, ret
    local c = _create_client()
    local db = c[db_name]

    db.testcoll:dropIndex("*")
    db.testcoll:drop()

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1, test_key2 = 1 })
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1, test_key2 = 2 })
    assert(ok and ret and ret.n == 1, err)

    ok, err, ret = db.testcoll:safe_insert({ test_key = 2, test_key2 = 3 })
    assert(ok and ret and ret.n == 1, err)

    local pipeline = {
        {
            ["$group"] = {
                _id = mongo.null,
                test_key_total = { ["$sum"] = "$test_key" },
                test_key2_total = { ["$sum"] = "$test_key2" },
            }
        }
    }
    ret = db:runCommand("aggregate", "testcoll", "pipeline", pipeline, "cursor", {})
    assert(ret and ret.cursor.firstBatch[1].test_key_total == 4)
    assert(ret and ret.cursor.firstBatch[1].test_key2_total == 6)
end

function test_expire_index()
    local ok, err, ret
    local c = _create_client()
    local db = c[db_name]

    db.testcoll:dropIndex("*")
    db.testcoll:drop()

    db.testcoll:ensureIndex({ test_key = 1 }, { unique = true, name = "test_key_index", expireAfterSeconds = 1, })
    db.testcoll:ensureIndex({ test_date = 1 }, { expireAfterSeconds = 1, })

    ok, err, ret = db.testcoll:safe_insert({ test_key = 1, test_date = bson.date(os.time()) })
    assert(ok and ret and ret.n == 1, err)

    ret = db.testcoll:findOne({ test_key = 1 })
    assert(ret and ret.test_key == 1)

    for i = 1, 60 do
        skynet.sleep(100);
        print("check expire", i)
        ret = db.testcoll:findOne({ test_key = 1 })
        if ret == nil then
            return
        end
    end
    print("test expire index failed")
    assert(false, "test expire index failed");
end

local function test_safe_batch_insert()
    local ok, err, ret
    local c = _create_client()
    local db = c[db_name]

    db.testcoll:drop()

    local docs, length = {}, 10
    for i = 1, length do
        table.insert(docs, { test_key = i })
    end

    db.testcoll:safe_batch_insert(docs)

    local ret = db.testcoll:find()
    assert(length == ret:count(), "test safe batch insert failed")
end

skynet.start(function()
    if username then
        print("Test auth")
        test_auth()
    end
    print("Test insert without index")
    test_insert_without_index()
    print("Test insert index")
    test_insert_with_index()
    print("Test find and remove")
    test_find_and_remove()
    print("Test runCommand")
    test_runcommand()
    print("Test expire index")
    test_expire_index()
    print("test safe batch insert")
    test_safe_batch_insert()
    print("mongodb test finish.");
end)
