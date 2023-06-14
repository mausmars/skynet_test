local function getTimeZone()
    local now = os.time()
end

local function test()
    -- os.time() 得到是当前时间的距离1970.1.1.08:00时间的秒数
    local now = os.time()
    print(now)

    local date = os.date()
    print(date)

    local time = os.time({ year = 1970, month = 1, day = 1, hour = 8, min = 0, sec = 0 })
    print(time)

    for i = 1, 0 do
        print("##########")
    end

end

test()