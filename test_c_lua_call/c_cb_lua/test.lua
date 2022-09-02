package.cpath = "./?.so" --so搜寻路劲
local cb = require("cb")

local function callback(a, b, c)
    print("callback a=" .. a .. " b=" .. b .. " c=" .. c)
end

function defcallback(a, b, c)
    print("defcallback a=" .. a .. " b=" .. b .. " c=" .. c)
end

local function watch(a, b, c)
    print("### lua watch a=" .. a .. " b=" .. b .. " c=" .. c)
    return a + b + c
end

local function task()
    cb.setwatch2(watch)
    print("task over")
end

--===================================
local function handle_io()
    local token = coroutine.running()
    print("handle_io token= ", token)
    local function callback()
        print("### callback 1")
        print("coroutine status ", coroutine.status(token))
        print("唤醒协程 ", token)
        coroutine.resume(token)    --唤醒
        print("### callback 2")
    end
    -- 模拟io操作
    cb.io(callback)
    print("挂起协程! start")
    coroutine.yield()
    print("挂起协程! over")
end

-- 启动协程
local co = coroutine.create(handle_io)
coroutine.resume(co)
co = nil
--======================================
--local co = coroutine.create(task)
--coroutine.resume(co)
--co = nil
--======================================
--cb.setwatch(watch)
--======================================
--cb.setnotify(callback)
--cb.testnotify()
--======================================
--cb.testenv()
--======================================

os.execute("sleep " .. 6)
print "test over!"