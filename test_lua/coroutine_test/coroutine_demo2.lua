local productorco_co
local consumer_co1
local consumer_co2

local function productor()
    for i = 1, 100 do
        -- 将生产的物品发送给消费者
        coroutine.yield(i)     -- x表示需要发送的值，值返回以后，就挂起该协同程序
    end
end

local function consumer(name)
    while true do
        -- 从生产者那里得到物品
        local state = coroutine.status(productorco_co)
        if state == "dead" then
            break
        end
        local status, i = coroutine.resume(productorco_co)
        print(name, "result ", i)
    end
end

-- 启动程序
productorco_co = coroutine.create(productor)
consumer_co1 = coroutine.create(consumer)
consumer_co2 = coroutine.create(consumer)

print("main", coroutine.resume(productorco_co))
print("main", coroutine.resume(consumer_co1, "co1"))
print("main", coroutine.resume(consumer_co2, "co2"))

print("end")