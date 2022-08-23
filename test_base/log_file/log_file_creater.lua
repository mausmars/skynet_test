local lfs = require("lfs")
local skynet = require("skynet")

local log_path = skynet.getenv("log_path")

local File_Interval_Time = 15       -- 每15秒创建一个日志文件

local File_Separator = "/"
local Folder_Template = "%s" .. File_Separator .. "%s"

local function format_time(time)
    local temp_date = os.date("*t", time)
    local resultTime = os.time({ year = temp_date.year, month = temp_date.month, day = temp_date.day, hour = temp_date.hour, min = temp_date.min, sec = 0 })
    return os.date("%Y-%m-%d-%H-%M-%S", resultTime)
end

local LogFileCreater = {}

function LogFileCreater.new(log_path)
    local data = {}
    data.log_path = log_path
    return setmetatable(data, { __index = LogFileCreater })
end

function LogFileCreater:init()
    --self:remove_file()
    self:create_file()
end

function LogFileCreater:remove_file()
    --清空测试目录
    for file in lfs.dir(self.log_path) do
        if file ~= "." and file ~= ".." then
            local filePaht = self.log_path .. "/" .. file
            print(filePaht)
            os.remove(filePaht)
        end
    end
end

function LogFileCreater:file_key()
    local time = math.floor(skynet.time())
    local folder_name = format_time(time)
    local file_name = math.floor(time / File_Interval_Time)
    return folder_name, file_name
end

function LogFileCreater:create_file()
    --每15秒创建一个日志文件，每1秒写入一条数据
    local key = nil
    local file = nil
    local index = 0
    for _ = 1, 300 do
        local folder_name, file_name = self:file_key()
        if key ~= file_name then
            if file ~= nil then
                file:close()
            end
            index = 1
            key = file_name
            local path = string.format(Folder_Template, self.log_path, folder_name)
            lfs.mkdir(path)
            local filePaht = path .. File_Separator .. key .. ".log"
            file = io.open(filePaht, "a+")
        end
        file:write(key .. "_" .. index .. "\r\n")
        index = index + 1
        skynet.sleep(100)
    end
    print("exit create_file()!")
end

local function test()
    local creater = LogFileCreater.new(log_path)
    creater:init()
end

skynet.start(function()
    test()
    skynet.exit()
end)