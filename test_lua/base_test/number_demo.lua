--Lua 5.3 支持的最大整数为2^63,而Lua 5.2支持的最大整数为2^53,由于5.2及以下版本没有整数，
--所以跟整数相关的函数都不支持，如math.type()、math.maxinteger、math.mininteger、math.tointeger等

local function test()
    print("math.maxinteger v=", math.maxinteger)
    print("math.mininteger v=", math.mininteger)
    print("math.tointeger v=", math.tointeger)
    print("--------------------------------------")
    print("math.maxinteger+1 v=", math.maxinteger + 1)
    print("math.mininteger-1 v=", math.mininteger - 1)
    print("--------------------------------------")
    print(math.type(3)) -- integer
    print(math.type(3.0))-- float
    print("--------------------------------------")
    print("0xff v=", 0xff)
    print("--------------------------------------")
    print(string.format("%a", 419))
    print("--------------------------------------")
    print("math.random() v=", math.random())                     --[0,1)
    print("math.random(6) v=", math.random(6))              --[1,6]
    print("math.random(6, 7) v=", math.random(6, 7))    --[6,7]
    print("--------------------------------------")
    print("math.floor(3.3) v=", math.floor(3.3))
    print("math.floor(-3.3) v=", math.floor(-3.3))
    print("math.ceil(3.3) v=", math.ceil(3.3))
    print("math.ceil(-3.3) v=", math.ceil(-3.3))
    print("math.modf(3.3) v=", math.modf(3.3))
    print("math.modf(-3.3) v=", math.modf(-3.3))    --modf 向0取整,并会返回小数部分作为第二个结果
    local v1, v2 = math.modf(3.3)
    print("math.modf(3.3) v1=%d v2=%d", v1, v2)

    print("--------------------------------------")
    print("-3+0.0 v=", -3 + 0.0)        --整型转行成浮点型

    print("0x7f+0.0 v=", 0x7f + 0.0)    --整型转行成浮点型
    print("4.0 | 0 v=", 4.0 | 0)        --浮点型转行成整型
end

test()