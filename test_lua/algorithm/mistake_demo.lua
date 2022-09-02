-- 相对误差=（测量值measured-真实值actual）/真实值actual
local function mistake(measured, actual, precision)
    local mistake = (measured - actual) / actual
    if mistake < 0 then
        mistake = -mistake
    end
    mistake = math.floor(mistake * 1000) / 1000 --精确到 0.001
    return mistake
end

local function test()
    local actual = 100
    print("100      相对误差  ", mistake(100, actual))
    print("99.999   相对误差  ", mistake(99.999, actual))
    print("99.99    相对误差  ", mistake(99.99, actual))
    print("99.9     相对误差  ", mistake(99.9, actual))
    print("99       相对误差  ", mistake(99, actual))
    print("95       相对误差  ", mistake(95, actual))
    print("90       相对误差  ", mistake(90, actual))
    print("80       相对误差  ", mistake(80, actual))
    print("50       相对误差  ", mistake(50, actual))
    print("0        相对误差  ", mistake(0, actual))
    print("100.001  相对误差  ", mistake(100.001, actual))
    print("100.01   相对误差  ", mistake(100.01, actual))
    print("100.1    相对误差  ", mistake(100.1, actual))
    print("101      相对误差  ", mistake(101, actual))
    print("10000    相对误差  ", mistake(10000, actual))
    print("199.99   相对误差  ", mistake(199.99, actual))
end

test()