local function time_2_date(time)
    return os.date("%Y-%m-%d %H:%M:%S", time)
end

--t= { 2023, 04, 30, 00, 00, 00 }
local function date_2_time(t)
    return os.time {
        year = t[1],
        month = t[2],
        day = t[3],
        hour = t[4],
        min = t[5],
        sec = t[6],
    }
end

local function test()
    local time = os.time({ year = 1970, month = 1, day = 1, hour = 8, min = 0, sec = 0 })
    print("格林尼治 " .. time)

    local t1 = { 1970, 01, 01, 08, 00, 00 }
    local time1 = date_2_time(t1)
    print("格林尼治 " .. time1)

    print("格林尼治 " .. time_2_date(0))

    local t2 = { 2023, 04, 30, 00, 00, 00 }
    local time2 = date_2_time(t2)
    print(time2)

    print("6t=", time_2_date(1682651880))
    print("ct=", time_2_date(1683085874))
    print("ot=", time_2_date(1683043200))
    --2023|05|04|00|00|00
    print("test=", time_2_date(1687640400))


    print("test2=", time_2_date(1687122000))

end

test()