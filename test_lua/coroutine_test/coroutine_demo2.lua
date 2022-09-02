local productorco_co
local consumer_co

local function receive()
    local status, value = coroutine.resume(productorco_co)
    return value
end

local function send(x)
    coroutine.yield(x)     -- x表示需要发送的值，值返回以后，就挂起该协同程序
end

local function productor()
    local i = 0
    while true do
        i = i + 1
        send(i)     -- 将生产的物品发送给消费者
    end
end

local function consumer()
    while true do
        local i = receive()     -- 从生产者那里得到物品
        print(i)
    end
end

-- 启动程序
productorco_co = coroutine.create(productor)
--consumer_co = coroutine.create(consumer)
consumer()

print("end")