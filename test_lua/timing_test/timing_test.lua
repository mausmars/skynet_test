local TimingMgr = require "timing"

local function trigger_func(params)
    print("trigger_func", params)
end

local function test()
    print("start test")
    local timingMgr = TimingMgr.new()

    local interval_time = 20

    local target_time = os.time() + interval_time
    local repeat_count = 2
    local repeat_interval = interval_time
    timingMgr:register(target_time, repeat_count, repeat_interval, trigger_func, { 1, 2 })

    for i = 1, 100 do
        timingMgr:tick()

        os.execute("sleep " .. 1)
    end
end

test()




