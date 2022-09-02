local skynet = require "skynet"
local coroutine = require "skynet.coroutine"

require "skynet.manager"
local cb = require("cb")

local fork_count = tonumber(skynet.getenv("fork_count"))

local CallBackService = {}

--模拟处理io
local function handle_io()
    local token = coroutine.running()
    print("handle_io token= ", token)
    local function callback()
        print("### callback1")
        print("coroutine status ", coroutine.status(token))
        --skynet.wakeup(token)    --唤醒
        coroutine.resume(token)    --唤醒
        print("### callback2")
    end
    cb.io(callback)
    print("挂起协程! start")
    skynet.wait(token)       --挂起
    print("挂起协程! over")
end

function CallBackService.new()
    local data = {}
    return setmetatable(data, { __index = CallBackService })
end

function CallBackService:start_fork()
    local co = skynet.fork(function()
        handle_io()
    end)
    return co
end

function CallBackService:startup()
    print("CallBackService startup! ")
    for i = 1, fork_count do
        local co = self:start_fork()
    end
end

local service = CallBackService.new()

skynet.start(function()
    print("Test service start!")
    service:startup()
end)