-- ./skynet test_base/reload_test/config
local skynet = require "skynet"
local codecache = require "skynet.codecache"

local function table2string(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)
    if name then
        tmp = tmp .. name .. " = "
    end
    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. table2string(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end
    return tmp
end

local function test1()
    print("test start")

    local social_url = require("social_url")
    print("require 1", social_url)
    print("social_url=", table2string(social_url))

    print("wait 10s")
    skynet.sleep(1000)

    codecache.clear()
    package.loaded["social_url"] = nil
    social_url = require("social_url")
    print("require 2", social_url)
    print("social_url=", table2string(social_url))

    print("test end")
end

skynet.start(function()
    skynet.newservice("debug_console", 7853)

    test1()
end)

-- nc 127.0.0.1 7853
-- clearcache

