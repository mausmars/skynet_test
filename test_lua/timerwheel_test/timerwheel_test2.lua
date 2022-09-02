local timerwheel = require "timerwheel"
--local luasocket = require "luasocket"

local function err_handle(info)
    print("err_handle info:" .. info)
end

local config = {}
config.precision = 0.05
config.ringsize = 72000
--config.now = luasocket.gettime
config.err_handler = err_handle

local wheel = timerwheel.new(config)

local cb = function(arg)
    print("timer executed with: ", arg)
end

local produce = function()
    print("produce function")
    for i = 1, 100 do
        local id = wheel:set(0.1, cb, "hello world " .. i)
        print("put")
    end
end

local consume = function()
    print("consume function")
    for i = 1, 100 do
        wheel:step()
        if wheel:count() <= 0 then
            break
        end
        print("step")
        -- 这个sleep睡的是线程?
        os.execute("sleep " .. 1)  -- 10ms
    end
end

local produce_co = coroutine.create(produce)
local consume_co = coroutine.create(consume)

print("produce_co " .. tostring(produce_co))
print("consume_co " .. tostring(consume_co))

print("main", coroutine.resume(produce_co))
print("main", coroutine.resume(consume_co))

os.execute("sleep " .. 5)
print("end")
