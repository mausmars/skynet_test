local queue = require "queue"

local count = 1

local function test1()
    local q = queue.new()

    --for i = 1, count do
    --    q:rpush(i)
    --end
    for i = 1, count do
        local v = q:lpop()
        print(v)
    end
end

local function test2()
    local q = {}
    for i = 1, count do
        table.insert(q, i)
    end
    for i = 1, count do
        local v = table.remove(q, 1)
        --print(v)
    end
end
local startTime = os.time();
test1()
print("linked list 时间 " .. (os.time() - startTime))

--startTime = os.time();
--test2()
--print("table 时间 " .. (os.time() - startTime))