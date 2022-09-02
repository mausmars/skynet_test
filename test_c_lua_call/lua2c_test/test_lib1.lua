package.cpath = "./createlib1/?.so" --so搜寻路劲
local ctest = require "ctest" -- 对应luaopen_test中的myLualib

local function test()
    print("--- test ---")
    ctest.test1(123)
    ctest.test2("hello world")
    ctest.test3(456, "yangx")
end

test()

