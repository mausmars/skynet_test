-- 关闭jit
if jit then
    jit.off()
end

local data = {} -- 一个大的table，用来模拟常驻内存的table，测试的时候使用的是drop_data.lua里面的数据，该data有8655个table元素（在gc的时候产生消耗），60810个元素（包括table元素，会在遍历的时候产生消耗）

function deepCopyTable(t)
    local ret = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            ret[k] = deepCopyTable(v)
        else
            ret[k] = v
        end
    end
    return ret
end

datas = {}

-- 循环产生更多的常驻内存的table，可以看到总共会有865W+的table元素和总共6000W+的元素
for i = 1, 1000 do
    datas[#datas+1] = deepCopyTable(data)
end

print("begin")
local time = os.clock()
for i = 1, 2000000 do
    -- 模拟产生临时变量
    local temp = deepCopyTable(data)

    -- 每10次计算一次时间和内存
    if i % 10 == 0 then
        local time_temp = os.clock()
        print(collectgarbage("count"), time_temp-time)
        time = time_temp
    end
end