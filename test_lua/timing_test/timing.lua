--- 做这个是为了避免频繁的获取系统时间，按tick每秒触发自己减秒倒计时，
---但是tick如果有其他操作，可能会导致时间的不准确，需要一段时间做时间差的重新计算，保证尽量的精确
--TODO 查了一下50万次系统时间调用 7ms，感觉这个意义也不大，当写着玩了

local check_time = 5                   -- 时间差小于该时间最精准校验 秒
local reset_td_interval = 5             -- 重置时间差时间           秒

local Timing = {}

function Timing.new(id, target_time, repeat_count, repeat_interval, trigger_func, trigger_param)
    local data = {}
    data.id = id
    data.state = 1                          -- 状态 0-失效，1-可用
    data.repeat_interval = repeat_interval  -- 重复间隔  秒
    data.repeat_count = repeat_count        -- 重复次数 (小于-永远重复; 0-不重复)
    data.target_time = target_time          -- 目标时间 秒

    data.trigger_func = trigger_func        -- 触发函数
    data.trigger_param = trigger_param      -- 触发参数
    data.trigger_count = 0                  -- 触发次数
    data.td = 0                             -- 时间差   秒
    data.reset_td_interval = 0              -- 记录重置时间差间隔 秒
    local obj = setmetatable(data, { __index = Timing })
    obj:reset_time_difference()
    return obj
end

function Timing:current_timestamp()
    return os.time()
end

--重置时间差
function Timing:reset_time_difference()
    self.td = self.target_time - self:current_timestamp()
    print("reset_time_difference td=", self.td)
    self.reset_td_interval = 0
end

function Timing:trigger()
    print("trigger")
    if self.trigger_func ~= nil then
        self.trigger_func(self.trigger_param)
    end
    self.trigger_count = self.trigger_count + 1 --触发次数加1
    if self.repeat_count < 0 or self.trigger_count < self.repeat_count then
        --继续执行
        self.target_time = self.target_time + self.repeat_interval
        self:reset_time_difference()
    else
        --退出
        self.state = 0
    end
end

function Timing:tick()
    print("tick")
    if self.td <= 0 then
        self:trigger() --触发
    else
        self.td = self.td - 1
        self.reset_td_interval = self.reset_td_interval + 1

        if self.reset_td_interval >= reset_td_interval then
            self:reset_time_difference()
        end

        if self.td < check_time then
            --TODO 做这个就是为了避免频繁的获取系统时间
            --如果在check_time时间范围内，做精准时间判断
            if self.target_time <= self:current_timestamp() then
                self:trigger() --触发
            end
        end
    end
end

local TimingMgr = {}

function TimingMgr.new()
    local data = {}
    data.timings = {}
    data.id_creater = 0
    return setmetatable(data, { __index = TimingMgr })
end

function TimingMgr:create_id()
    self.id_creater = self.id_creater + 1
    return self.id_creater
end

function TimingMgr:register(target_time, repeat_count, repeat_interval, trigger_func, trigger_param)
    local id = self:create_id()
    local timing = Timing.new(id, target_time, repeat_count, repeat_interval, trigger_func, trigger_param)
    self.timings[timing.id] = timing
    return timing
end

function TimingMgr:tick()
    for _, timing in pairs(self.timings) do
        if timing.state < 1 then
            self.timings[timing.id] = nil
        else
            timing:tick()
        end
    end
end

return TimingMgr