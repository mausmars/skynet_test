local skynet = require "skynet"
local redis = require 'skynet.db.redis'

local RedisService = {}

function RedisService.new(host, port, auth, db, watch_count)
    local data = {}
    data.config = { host = host, port = port, auth = auth, db = db }
    data.db = nil
    data.channel_watchs = {}    -- {频道名字:watch}
    data.watchwraps = {}            -- watch 池 数组
    data.watch_count = watch_count
    return setmetatable(data, { __index = RedisService })
end

function RedisService:create_watchwrap(watch)
    local data = {}
    data.watch = watch
    data.is_close = false
    return data
end

function RedisService:start()
    print("redisService start!")
    --连接redis数据库
    self.db = redis.connect(self.config)
    for _ = 1, self.watch_count do
        local watch = redis.watch(self.config)
        local watchwrap = self:create_watchwrap(watch)
        table.insert(self.watchwraps, watchwrap)
    end
    -- 接受消息
    self:receive()
end

function RedisService:shutdown()
    print("redisService shutdown!")
    for _, watchwrap in pairs(self.watchwraps) do
        watchwrap.is_close = true
        watchwrap.watch:disconnect()
    end
end

function RedisService:receive()
    print("redisService receive!")
    for _, watchwrap in pairs(self.watchwraps) do
        skynet.fork(function()
            local now = os.time()
            local ok, ret = xpcall(function()
                while not watchwrap.is_close do
                    skynet.sleep(1)
                    local mes = watchwrap.watch:message() -- 监听到的消息内容 在这里写业务逻辑
                    print("### receive", mes)
                end
            end, debug.traceback, now)
            if not ok and ret then
            end
        end)
    end
end

-- 注册订阅
function RedisService:subscribe(channel)
    print("redisService subscribe! channel=" .. channel)
    if self.channel_watchs[channel] == nil then
        local index = math.random(1, #self.watchwraps)
        local watchwrap = self.watchwraps[index]
        self.channel_watchs[channel] = watchwrap
        watchwrap.watch:subscribe(channel)
    end
end

-- 关闭订阅
function RedisService:unsubscribe(channel)
    print("redisService unsubscribe! channel=" .. channel)
    local watchwrap = self.channel_watchs[channel]
    if watchwrap ~= nil then
        watchwrap.watch:unsubscribe(channel)
        self.channel_watchs[channel] = nil
    end
end

-- 发布
function RedisService:publish(channel, msg)
    print("redisService publish! channel=" .. channel .. ", msg=" .. msg)
    self.db:publish(channel, msg)
end

return RedisService