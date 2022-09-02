local util = require "util"

--local isok, vrf = pcall(util.sum, util, 10, 20, 1)
--local isok, result = pcall(util.sum, { test = 10 }, 10, 20, 1)
local isok, result = pcall(util.sum, util, 10, 20, "a")
print("isok=" .. tostring(isok))
print("result=" .. tostring(result)) --结果 or 错误信息

print("continue run...")