-- https://regexr.com/

local function match1()
    local s = "Deadline is 30/05/1999, firm"
    local date = "%d%d/%d%d/%d%d%d%d"
    print(string.match(s, date))
end

local function match2()
    -- + 匹配1次或多次
    print(string.match("hello world 123", "%w+ %w+")) -->  hello world
    print(string.match("helle world 123", "[%w %d]+")) --> hello world 123
    -- ? 匹配0或1次 （匹配一个有符号数）
    print(string.match("the number is: +123", "[+-]?%d+")) --> +123
    print(string.match("the number is: 123", "[+-]?%d+")) --> 123
    print(string.match("the number is: -123", "[+-]?%d+")) --> -123
    -- * 匹配0次或多次
    print(string.match("abc123abc", "%a+%d*%a+")) --> abc123abc
    print(string.match("abcabc", "%a+%d*%a+")) --> abcabc
end

local function match3()
    local str = "channelOrderId=2000000029412173&paymentExtend&orderId=2011378700&goodsId=Combo_XS_12&sign=49e804c1c9495e59bcc57b3bebb19ec7&startTs=1649494776000&language=zh-Hans-CN&userId=2332296&serverId&platform=apple_cn&gameExtend=2&isTest=1&price=12.00&appId=combo&endTs=1649494784000&zoneId=1&action=coin&dcAppId=combo_ioscn_prod&channelName=apple&currency=CNY&location=CN&sku=com.happyelements.combo.cn.ios2"
    local date = "(.-)=(.-)&"
    --print(string.match(str, date))

    for k, v in string.gmatch(str, date) do
        for k1, v1 in string.gmatch(k, "(.-)&(.-)") do
            print("@@@ ", k1, v1)
        end
        print("### ", k, v)
    end
end

local function match4()
    local str = "channelOrderId=2000000029412173&paymentExtend&paymentExtend2&orderId=2011378700&goodsId=Combo_XS_12&sign=49e804c1c9495e59bcc57b3bebb19ec7&startTs=1649494776000&language=zh-Hans-CN&userId=2332296&serverId&platform=apple_cn&gameExtend=2&isTest=1&price=12.00&appId=combo&endTs=1649494784000&zoneId=1&action=coin&dcAppId=combo_ioscn_prod&channelName=apple&currency=CNY&location=CN&sku=com.happyelements.combo.cn.ios2"
    local date = "([^=&]+)(=?([^&]*))"

    --print(string.match(str, date))
    --local str = "&a=&b&"
    for k, v, x in string.gmatch(str, date) do
        if x == "" then
            print("@@@ ", k)
        end
        print("### ", k, x)
    end
    print("---------------")
end

local function match5()
    local str = "LF-0102000388_windward_20220727_16.game.bi.log"
    local date = ".game.bi.log"

    print(string.match(str, date))
end

local function match6()
    local BufSize = 2 ^ 13              -- 文件读取缓冲区大小 8K
    local Content_Match_Template = "bi content=(.-)[\r\n]"

    local in_put = io.open("../../test_file/test.log", "a+")
    while true do
        local lines, _ = in_put:read(BufSize, "*line")
        if not lines then
            break
        end
        print(lines)
        for line in string.gmatch(lines, Content_Match_Template) do

            print("line=", line)
        end
    end
    in_put:close()
end

local function match7()
    local BufSize = 2 ^ 13              -- 文件读取缓冲区大小 8K
    local Separator = ","
    local Content_Match_Template = "(%d+)" .. Separator .. "(%w+-%w+-%w+-%w+-%w+-%w+)" .. Separator .. "(%w+_%w+.%w+)" .. Separator .. "(%d+)" .. Separator .. "(%d+)"

    local in_put = io.open("../../test_file/test2.txt", "a+")
    while true do
        local lines, _ = in_put:read(BufSize, "*line")
        if not lines then
            break
        end
        print(lines)
        for row_id, upper_dir, file_name, r, state in string.gmatch(lines, Content_Match_Template) do
            print(row_id, upper_dir, file_name, r, state)
        end
    end
    in_put:close()
end

local function match8()
    local str = "2022-07-27"
    local date = "%d%d%d%d%-%d%d%-%d%d"

    print(string.match(str, date))
end

local function match9()
    local str = "LF-0102000388_windward_20220727_16.game.bi.log"
    local date = "(%d%d%d%d)(%d%d)(%d%d)%_(%d%d)"

    for year, month, day, hour in string.gmatch(str, date) do
        print(year, month, day, hour)
        local time = os.time({ day = day, month = month, year = year, hour = hour, minute = 0, second = 0 })
        print(time)
    end
end

local function match10()
    local BufSize = 2 ^ 13              -- 文件读取缓冲区大小 8K
    local Separator = ","
    local Content_Match_Template = "(%d+)" .. Separator .. "(%d+[-]%d+[-]%d+)" .. Separator .. "(.-)" .. Separator .. "(%d+)" .. Separator .. "(%d+)"

    local in_put = io.open("../../test_file/test3.txt", "a+")
    while true do
        local lines, _ = in_put:read(BufSize, "*line")
        if not lines then
            break
        end
        print(lines)
        for row_id, upper_dir, file_name, r, state in string.gmatch(lines, Content_Match_Template) do
            print("@@@ ", row_id, upper_dir, file_name, r, state)
        end
    end
    in_put:close()
end

local function match11()
    --local url = "/survey?pid=11111&surveyid=1"
    local url = "/api/webhooks/ip"
    local Url_Template = "(/.-)[?](.*)"

    local path, param = string.match(url, Url_Template)
    print("path=", path)
    print("param=", param)
end

local function match12()
    local Time_Template = "(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)"
    local date = "2021-01-26 14:00:00"

    local y, m, d, h, min, s = string.match(date, Time_Template)
    print(y, m, d, h, min, s)

    local t = { string.match(date, Time_Template) }
    local time = os.time { year = t[1], month = t[2], day = t[3], hour = t[4], minute = t[5], second = t[6] }
    print("time ", time)

    print("os.time", os.time())
end

local function match13()
    local Url_Template = "https://.-/.-/(%d-)/.-/-"
    local data = "https://wj.qq.com/s2/10315407/e7db/"

    local num = string.match(data, Url_Template)
    print("num ", num)
end

--match1()
--match2()
--match3()
--match4()
--match5()
--match6()
--match7()
--match8()
--match9()
--match10()
--match11()
--match12()
match13()