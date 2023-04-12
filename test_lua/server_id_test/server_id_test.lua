local XOR_KEY = 2333333

local function GET_GS_ID(pid)
    local pid_num = tonumber(pid)
    if not pid_num then
        return 0
    end
    return math.floor((pid_num ~ XOR_KEY) % 1000)
end

print("797526078 ", GET_GS_ID(797526078))
print("804579871 ", GET_GS_ID(804579871))
print("808619214 ", GET_GS_ID(808619214))

print("816168335 ", GET_GS_ID(816168335))
print("825749086 ", GET_GS_ID(825749086))

print("797601151 ", GET_GS_ID(797601151))

print("797638135 ", GET_GS_ID(797638135))

print("797661633 ", GET_GS_ID(797661633))

print("3964640 ", GET_GS_ID(3964640))

print("813157343 ", GET_GS_ID(813157343))

print("871673942 ", GET_GS_ID(871673942))
print("798059102 ", GET_GS_ID(798059102))

print("797596588 ", GET_GS_ID(797596588))

print("843969935 ", GET_GS_ID(843969935))
print("807133942 ", GET_GS_ID(807133942))

--作弊
print("875618284 ", GET_GS_ID(875618284))
print("815091358 ", GET_GS_ID(815091358))
print("893536407 ", GET_GS_ID(893536407))
print("842525031 ", GET_GS_ID(842525031))

--疑似作弊
print("899708652 ", GET_GS_ID(899708652))



--local AutoGenConfig_Battle = { md5 = "8f2c4a276924dd4346bdb0aa71c39a46" } return AutoGenConfig_Battle

--
--local AutoGenConfig_Battle = { md5 = "c91e96a348c1721d16f52afac1d5524a" } return AutoGenConfig_Battle

--pid:816937593 check_client_version cur_version ~= v 8f2c4a276924dd4346bdb0aa71c39a46~=version:21faa41e011352de6de2c1ab246ded9f