local skynet = require("skynet")

local continue_time = 100

local test_file = "test_base/file_rw_test/test.txt"

local Service = {}

function Service.new()
    local data = {}
    data.file_path = test_file
    data.row = 0
    return setmetatable(data, { __index = Service })
end

function Service:startup()
    print("Service write startup!")
end

function Service:gain_ctime()
    return math.floor(skynet.time())
end

function Service:write_file(id)
    print("Service write_file! id=" .. id)

    skynet.sleep(1)

    local start_time = self:gain_ctime()
    while true do
        local count = math.random(1, 5)

        local in_out_put = io.open(self.file_path, "a")
        for i = 1, count do
            self.row = self.row + 1
            local c = "content=[servcie id=" .. id .. " count=" .. count .. " row=" .. self.row .. "]\n"
            in_out_put:write(c)
        end
        in_out_put:flush()
        in_out_put:close()
        --print("write id=" .. id .. " count=" .. count .. " row=" .. self.row)
        if self:gain_ctime() - start_time > continue_time then
            print(">>> write_file id=" .. id .. ", row=" .. self.row)
            break
        else
            skynet.sleep(math.random(10, 20))
        end
    end
end

local service = Service.new()
local CMD = {}

function CMD.write_file(id)
    return service:write_file(id)
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

