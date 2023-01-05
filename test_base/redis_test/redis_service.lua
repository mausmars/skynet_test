local skynet = require "skynet"
local redis = require 'skynet.db.redis'

local RedisService = {}

function RedisService.new(host, port, auth, db)
    local data = {}
    data.config = { host = host, port = port, auth = auth, db = db }
    data.db = nil
    data.channel_watchs = {}        --{频道名字:watch}
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
end

function RedisService:shutdown()
    print("redisService shutdown!")

end

function RedisService:receive(watchwrap)
    print("redisService receive!")
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

-- 注册订阅
function RedisService:subscribe(channel)
    print("redisService subscribe! channel=" .. channel)
    if self.channel_watchs[channel] == nil then
        local watch = redis.watch(self.config)
        local watchwrap = self:create_watchwrap(watch)
        self.channel_watchs[channel] = watchwrap
        watch:subscribe(channel)
        self:receive(watchwrap)
    end
end

-- 关闭订阅
function RedisService:unsubscribe(channel)
    print("redisService unsubscribe!")
    local watchwrap = self.channel_watchs[channel]
    if watchwrap ~= nil then
        watchwrap.watch:unsubscribe(channel)
        watchwrap.is_close = true
        self.channel_watchs[channel] = nil
    end
end

-- 发布
function RedisService:publish(channel, msg)
    print("redisService publish!")
    self.db:publish(channel, msg)
end

return RedisService