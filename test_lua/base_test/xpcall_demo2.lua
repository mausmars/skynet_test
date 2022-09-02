local util = require "util"

local function err_handle(info)
    print("err_handle info:" .. info)
end

local function pack(isok, ...)
    print("isok=" .. tostring(isok))
    --print("result 长度=" .. tostring(#result))    --结果 or nil

    local result, a, b, c = ...
    print("result=" .. tostring(result))
    print("a=" .. tostring(a))
    print("b=" .. tostring(b))
    print("c=" .. tostring(c))
    print("continue run...")
end

pack(xpcall(function()
    return util:sum(10, 20, 3)
end, err_handle))




