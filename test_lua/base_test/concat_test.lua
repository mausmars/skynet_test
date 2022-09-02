local socket = require "socket"

local strTbl = {}
for i = 1, 10000, 1 do
    strTbl[i] = "testString"
end

local resultStr = ""

-- 使用..连接字符串
local startTime = socket.gettime()
for _, v in pairs(strTbl) do
    resultStr = resultStr .. v
end
local endTime = socket.gettime()
print(".. used time->", endTime - startTime)

-- 使用table.concat连接字符串
startTime = socket.gettime()
resultStr = table.concat(strTbl)
endTime = socket.gettime()
print("concat used time->", endTime - startTime)
