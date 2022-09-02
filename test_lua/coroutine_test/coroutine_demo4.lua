local produce = function()
    for i = 1, 5 do
        print("produce")
        coroutine.yield()
        -- 这个sleep睡的是线程?
        os.execute("sleep " .. 1)  -- 10ms
    end
end

local consume = function(produce_co, name)
    for i = 1, 5 do
        print("consume_" .. name .. " a")
        coroutine.resume(produce_co)        --resume 堵塞等在
        print("consume_" .. name .. " b")
    end
end

local produce_co = coroutine.create(produce)
local consume_co1 = coroutine.create(consume)
local consume_co2 = coroutine.create(consume)

coroutine.resume(produce_co)
coroutine.resume(consume_co1, produce_co, "1")
coroutine.resume(consume_co2, produce_co, "2")

os.execute("sleep " .. 5)
print("end")