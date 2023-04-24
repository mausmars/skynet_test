local skynet = require("skynet")

local buf_size = 8 * 1024

local continue_time = 150
local test_file = "test_base/file_rw_test/test.txt"

local Log_Content_Match_Template = "content=(.-)[\r\n]"  --日志内容匹配





local str= "04-21 12:10:47.381308 BI   : 0000002f  [game/agent/bi_mgr.lua:362]content=[{\"server_area\":\"CHN\",\"sub_category\":\"\",\"appid\":\"combo_qa_prod\",\"client_time\":\"2023-04-21 12:10:47\",\"resource_info\":\"[{\\\"type\\\":22,\\\"id\\\":1,\\\"count\\\":197550},{\\\"type\\\":22,\\\"id\\\":5,\\\"count\\\":1057},{\\\"type\\\":22,\\\"id\\\":2,\\\"count\\\":8675},{\\\"type\\\":22,\\\"id\\\":4,\\\"count\\\":50},{\\\"type\\\":22,\\\"id\\\":6,\\\"count\\\":510},{\\\"type\\\":22,\\\"id\\\":7,\\\"count\\\":16000},{\\\"type\\\":22,\\\"id\\\":3,\\\"count\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3008,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3009,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3012,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3014,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3015,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3018,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3021,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3024,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2001,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2002,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2003,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2004,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2005,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2006,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2007,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2009,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2010,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2011,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2012,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2014,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2015,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2016,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2018,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2019,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2022,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2023,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2024,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1001,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1002,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1003,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1004,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1005,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1006,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1007,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1008,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1009,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":1010,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3027,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3002,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":2025,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3004,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3005,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3006,\\\"star\\\":0},{\\\"type\\\":6,\\\"level\\\":100,\\\"id\\\":3007,\\\"star\\\":0},{\\\"type\\\":48,\\\"id\\\":96,\\\"count\\\":1},{\\\"type\\\":48,\\\"id\\\":103,\\\"count\\\":10},{\\\"type\\\":48,\\\"id\\\":82,\\\"count\\\":23},{\\\"type\\\":48,\\\"id\\\":83,\\\"count\\\":2},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":107,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":108,\\\"num\\\":2},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":205,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":106,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":105,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":101,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":102,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":103,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":104,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":201,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":202,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":203,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":204,\\\"num\\\":2},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":301,\\\"num\\\":2},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":110,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":111,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":112,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":113,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":114,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":115,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":308,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":206,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":207,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":208,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":209,\\\"num\\\":2},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":210,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":211,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":116,\\\"num\\\":2},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":307,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":305,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":212,\\\"num\\\":1},{\\\"type\\\":82,\\\"level\\\":1,\\\"id\\\":109,\\\"num\\\":1},{\\\"type\\\":19,\\\"level\\\":1,\\\"id\\\":1},{\\\"type\\\":19,\\\"level\\\":1,\\\"id\\\":5},{\\\"type\\\":201,\\\"group_num\\\":1,\\\"id\\\":2,\\\"rank\\\":-1,\\\"level\\\":6,\\\"ticket_num\\\":63,\\\"count\\\":1201}]\",\"uid\":\"2334424\",\"user_level\":2,\"user_platform\":\"Dummy\",\"category\":\"resource_info\",\"event_id\":\"user_event\"}]"





local Service = {}

function Service.new()
    local data = {}
    data.file_path = test_file
    data.row = 0
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service read startup!")

end

function Service:gain_ctime()
    return math.floor(skynet.time())
end

function Service:read_file()
    print("Service read_file!")

    local start_time = self:gain_ctime()
    local input = io.open(self.file_path, "r")

    local size = 0
    while true do
        local line = input:read()
        if line ~= nil then
            print("" .. line)
            self.row = self.row + 1
            print("row = " .. self.row)

            size = size + string.len(line)
        else
            print("lines == nil row =" .. self.row)
        end

        if self:gain_ctime() - start_time > continue_time then
            break
        else
            if size >= buf_size then
                size = 0
                skynet.sleep(100)
            end
        end
    end
    input:close()
end

local service = Service.new()
local CMD = {}

function CMD.read_file()
    return service:read_file()
end

skynet.start(function()
    service:startup()

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
