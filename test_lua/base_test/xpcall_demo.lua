local util = require "util"

local function err_handle(info)
    print("err_handle info:" .. info)
end

local isok, result = xpcall(function()
    return util:sum(10, 20, 3)
end, err_handle)
--debug.traceback 可以打印debug栈

print("isok=" .. tostring(isok))
--print("result 长度=" .. tostring(#result))    --结果 or nil
print("result=" .. tostring(result))
print("continue run...")

