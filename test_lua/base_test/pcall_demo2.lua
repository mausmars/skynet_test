local util = require "util"

--local isok, vrf = pcall(util.sum, util, 10, 20, 1)
--local isok, result = pcall(util.sum, { test = 10 }, 10, 20, 1)

local function pack(isok, ...)
    print("isok=" .. tostring(isok))

    local result, a, b, c = ...
    print("result=" .. tostring(result)) --结果 or 错误信息
    print("a=" .. tostring(a))
    print("b=" .. tostring(b))
    print("c=" .. tostring(c))

    print("continue run...")

end

pack(pcall(util.sum, util, 10, 20, 3))
