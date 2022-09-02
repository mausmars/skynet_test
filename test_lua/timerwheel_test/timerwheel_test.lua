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

local id = wheel:set(0.1, cb, "hello world")
--local t = wheel:peek(10)
--if t then
--    print("next timer expires in ", t, " seconds")
--else
--    print("no timer scheduled for the next 10 seconds")
--end
for i = 1, 100 do
    wheel:step()
    if wheel:count() <= 0 then
        break
    end
    print("step " .. i)
    -- 这个sleep睡的是线程
    os.execute("sleep " .. 0.01)  -- 10ms
end
--wheel:cancel(id)
print("end")
