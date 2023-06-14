local XOR_KEY = 2333333

local XOR_KEY = 2333333
function MAKE_PID(serverid, index)
    return tostring(math.floor(index * 1000 + serverid) ~ XOR_KEY)
end

local function GET_GS_ID(pid)
    local pid_num = tonumber(pid)
    if not pid_num then
        return 0
    end
    return math.floor((pid_num ~ XOR_KEY) % 1000)
end

local function test1()
    local pid = MAKE_PID(501, 6)
    print("pid=", pid)
    local server_id = GET_GS_ID(pid)
    print("server_id=", server_id)
    local si = math.floor(server_id / 100)
    local server_index = si * 100
    print("server_index=", server_index)
end

test1()

print("-------------------------")
print("25893036", GET_GS_ID(25893036))  --作弊了
print("28875684", GET_GS_ID(28875684))  --作弊了

