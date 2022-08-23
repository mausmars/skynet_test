local lfs = require("lfs")
local skynet = require("skynet")
local inotify = require("inotify")

local log_path = skynet.getenv("log_path")
local store_file_path = skynet.getenv("store_file_path")

local Separator = ","    --分隔符
--行号id,文件名,处理完成行号,状态
local Content_Template = "%d" .. Separator .. "%s" .. Separator .. "%d" .. Separator .. "%s"
local Content_Match_Template = "(%d+)" .. Separator .. "(%w+.%w+)" .. Separator .. "(%d+)" .. Separator .. "(%d+)"
local Content_End = "_\r\n"
local Content_End_Length = string.len(Content_End)

local BufSize = 2 ^ 13              -- 文件读取缓冲区大小 8K
local Content_Length = 100          -- 字符串内容固定长度（字节）

local File_Interval_Time = 15       -- 每15秒创建一个日志文件
local Over_Delay_Finish_Time = 5    -- 延迟结束时间 秒
local Over_Delay_Check_Time = 100   -- 结束时的延迟检查时间 10ms
local Delay_Check_Time = 10         -- 正常时延迟检查时间 10ms

-- #############################################
-- 切分字符串
local function split(str, reps)
    local resultStrList = {}
    string.gsub(str, '[^' .. reps .. ']+', function(w)
        table.insert(resultStrList, w)
    end)
    return resultStrList
end

-- 当前时间产生的文件名字
local function file_key()
    local time = math.floor(skynet.time())
    local key = math.floor(time / File_Interval_Time)
    return key
end

-- #############################################
local LogSender = {}

function LogSender.new(log_file_mgr, file_name)
    local data = {}
    data.log_file_mgr = log_file_mgr
    data.row_id = 0             --行id
    data.file_name = file_name  --文件名
    data.row = 0                --发送完成的行
    data.state = 0              --状态 0未完成，1完成
    data.file_path = log_file_mgr.log_path .. "/" .. file_name
    data.file_key = split(self.file_name, ".")[1]           --文件key id
    return setmetatable(data, { __index = LogSender })
end

function LogSender:startup()
    self:read_log_file()
end

function LogSender:shutdown()
end

function LogSender:read_log_file()
    local times = 0
    while true do
        local cfile_key = file_key()
        print("file_key=" .. file_key .. ", cfile_key=" .. cfile_key)

        if file_key < cfile_key then
            self:_read_log_file()                   -- 读取文件发送
            skynet.sleep(Over_Delay_Check_Time)     -- 延迟1秒检查
            times = times + 1
            if times > Over_Delay_Finish_Time then
                -- 延迟10秒退出
                break
            end
        else
            self:_read_log_file()               -- 读取文件发送
            skynet.sleep(Delay_Check_Time)      -- 延迟1秒检查
        end
    end
end

function LogSender:_read_log_file()
    --检查文件是否发送完成
    local input = io.open(self.file_path, "r")
    local row = 0
    for content in input:lines() do
        if self.row == row then
            self:send_log(content)  --TODO 这里可能会很慢
            self.row = self.row + 1
            self:save()
        end
        row = row + 1
    end
    input:close()
end

function LogSender:send_log(content)
    print("send_log content=" .. content)
end

function LogSender:save()
    self.log_file_mgr:save(self)
end

function LogSender:store_content()
    local content = string.format(Content_Template, self.row_id, self.file_name, self.row, self.state)
    local length = string.len(content)
    content = content .. string.rep(" ", Content_Length - length - Content_End_Length) .. Content_End
    return content
end
-- #############################################
local LogFileMgr = {}

function LogFileMgr.new(store_file_path, log_path)
    local data = {}
    data.log_path = log_path
    data.store_file_path = store_file_path

    data.logSender_map = {}
    data.inotify_handle = nil
    data.log_path_watch = nil
    return setmetatable(data, { __index = LogFileMgr })
end

function LogFileMgr:startup()
    -- 添加log_path监听
    self:add_watch_log_path()
    -- 开打存储文件
    --self:new_file_check()
    --self:log_sender_start()
end

--监听log_path,目录的增加
function LogFileMgr:add_watch_log_path()
    self.inotify_handle = inotify.init()
    self.log_path_watch = self.inotify_handle:addwatch(self.log_path, inotify.IN_CREATE)
    local events = self.inotify_handle:read()
    for _, ev in ipairs(events) do
        print("new path created! name=", ev.name)
    end
end

function LogFileMgr:rem_watch_log_path()
    if self.inotify_handle ~= nil then
        self.inotify_handle:rmwatch(self.log_path_watch)
        self.inotify_handle:close()
    end
end

function LogFileMgr:shutdown()
    self:rem_watch_log_path()
end

function LogFileMgr:log_sender_start()
    for _, logSender in pairs(self.logSender_map) do
        if logSender.state <= 0 then
            skynet.fork(function()
                -- 每一个sender一个协程
                logSender:startup()
            end)
        end
    end
end

function LogFileMgr:new_file_check()
    local row = 0
    local in_out_put = io.open(self.store_file_path, "a+")
    while true do
        local lines, _ = in_out_put:read(BufSize, "*line")
        if not lines then
            break
        end
        for row_id, file_name, r, state in string.gmatch(lines, Content_Match_Template) do
            row = row + 1
            local logSender = LogSender.new(self, file_name)
            logSender.row_id = tonumber(row_id)
            logSender.row = tonumber(r)
            logSender.state = tonumber(state)
            self.logSender_map[logSender.file_name] = logSender
        end
    end

    for log_file in lfs.dir(self.log_path) do
        if log_file ~= "." and log_file ~= ".." then
            if self.logSender_map[log_file] == nil then
                row = row + 1
                local logSender = LogSender.new(self, log_file)
                logSender.row_id = row
                self.logSender_map[logSender.file_name] = logSender

                local store_content = logSender:store_content()
                in_out_put:write(store_content)
            end
        end
    end
    in_out_put:close()
end

function LogFileMgr:save(logSender)
    local in_out_put = io.open(self.store_file_path, "r+")

    --固定大小的内容可以直接跳到指定位置
    local offset = (logSender.row_id - 1) * Content_Length
    in_out_put:seek("set", offset)
    local content = logSender:store_content()
    in_out_put:write(content)
    print("### content=", content)
    in_out_put:close()
end

-- #############################################

local logFileMgr = LogFileMgr.new(store_file_path, log_path)

local CMD = {}

function CMD.exit()
    logFileMgr:shutdown()
end

skynet.start(function()
    logFileMgr:startup()

    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = CMD[tostring(cmd)]
        if f then
            local ret = table.pack(f(...))
            if session ~= 0 then
                skynet.ret(skynet.pack(table.unpack(ret)))
            end
        else
            print("unknown command %s", tostring(cmd))
        end
    end)
end)