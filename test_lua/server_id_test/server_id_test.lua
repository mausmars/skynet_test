local XOR_KEY = 2333333

local function GET_GS_ID(pid)
    local pid_num = tonumber(pid)
    if not pid_num then
        return 0
    end
    return math.floor((pid_num ~ XOR_KEY) % 1000)
end

print("814253414 ", GET_GS_ID(814253414))
print("834010366 ", GET_GS_ID(834010366))
print("868977753 ", GET_GS_ID(868977753))
print("887864511 ", GET_GS_ID(887864511))
print("797601151 ", GET_GS_ID(797601151))

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