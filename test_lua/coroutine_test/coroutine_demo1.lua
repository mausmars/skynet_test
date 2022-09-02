local function foo(a)
    print("foo a=" .. a)
    return coroutine.yield(2 * a)
end

local CoroutineContext = {}

local task = function(a, b)
    print(coroutine.running())
    print("task_1 ", a, b)

    local r, s = coroutine.yield(100 + a)
    print("task_1 yield return=", r, s)

    local r, s = coroutine.yield(a + b, a - b)
    print("task_1 ", r, s)
    return b, "end"
end

--启动协程 coroutine.create
local co1 = coroutine.create(task)
print("co1 " .. tostring(co1))

local co2 = coroutine.create(task)
print("co2 " .. tostring(co2))

print("main", coroutine.resume(co1, 1, 11))
print("main", coroutine.resume(co2, 2, 22))