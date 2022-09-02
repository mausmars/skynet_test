package.cpath = "./?.so" --so搜寻路劲
local closure = require "closure" -- 对应luaopen_test中的myLualib

local function test()
    local closure1 = closure.createclosure1(0, 0)
    local closure2 = closure.createclosure2(10, 10)

    print(closure1())
    -- 闭包里做了值修改的操作
    print(closure1())

    print(closure2())
    print(closure2())
end

test()


