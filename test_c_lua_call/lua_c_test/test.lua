package.cpath = "./?.so" --so搜寻路劲
local mylib = require "mylib"

mylib.test()        --> hello world
print(mylib.sum(1, 2, 3, 4, 5))

local t = mylib.map({ 1, 2, 3, 4 }, function(v)
    return v * v
end)

print("---------------------")
for k, v in ipairs(t) do
    print(k, v)
end

print("---------------------")
local c1 = mylib.newCounter()
print(c1(), c1(), c1()) --> 1 2 3

print("---------------------")
for k, v in pairs(debug.getregistry()) do
    print(k, v, type(v))
end
--1是主线程对象，其值和主协程里调用coroutine.running()得到的值一样。
--2就是全局变量，也就是默认的_G。
print("---------------------")
-- 注册表
local r = debug.getregistry()
--r[2] = 111
local test2 = require "test2"

print("---------------------")
local tinsert = table.insert
local tm = os.clock()
for i = 1, 3000 do
    local a = {}
    for i = 1, 10000 do
        --table.insert(a, i)    -- 性能差 table.insert是先从_ENV取出table，再从table取出insert
        --tinsert(a, i)         -- 用tinsert性能次之，保存为一个本地变量再调用
        a[#a + 1] = i           -- 性能最好
    end
end
print(">>>>>>", os.clock() - tm)