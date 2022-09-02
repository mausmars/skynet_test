local task = function(key)
    --print("task key=", key)
end

local coroutines = {}

for i = 1, 100 do
    local co = coroutine.create(task)

    local key = tostring(co)
    if coroutines[key] == nil then
        coroutines[key] = co
    else
        print("应用重复 线程id key=", key)
    end
end

for key, co in pairs(coroutines) do
    coroutine.resume(co, key)
end

