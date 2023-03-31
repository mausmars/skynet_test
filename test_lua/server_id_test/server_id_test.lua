local XOR_KEY = 2333333

local function GET_GS_ID(pid)
    local pid_num = tonumber(pid)
    if not pid_num then
        return 0
    end
    return math.floor((pid_num ~ XOR_KEY) % 1000)
end

print("797526078 ",GET_GS_ID(797526078))
print("804579871 ",GET_GS_ID(804579871))
print("808619214 ",GET_GS_ID(808619214))

print("816168335 ",GET_GS_ID(816168335))
print("815091358 ",GET_GS_ID(815091358))
print("825749086 ",GET_GS_ID(825749086))


print("797601151 ", GET_GS_ID(797601151))

print("797638135 ", GET_GS_ID(797638135))

print("797661633 ", GET_GS_ID(797661633))

-- 815091358

--local AutoGenConfig_Battle = { md5 = "8f2c4a276924dd4346bdb0aa71c39a46" } return AutoGenConfig_Battle

--
--local AutoGenConfig_Battle = { md5 = "c91e96a348c1721d16f52afac1d5524a" } return AutoGenConfig_Battle
