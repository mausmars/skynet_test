math.randomseed(os.time())

local function test1()
    local map = {}
    map.a = "a"
    map.b = "b"
    map.v = "v"
    map.h = "h"

    --遍历添加，会导致遍历不可控。
    for k, v in pairs(map) do
        if v == "b" then
            map.j = "j"
        end
        if v == "b" then
            map.k = "k"
        end
        print(k .. "   " .. v)
    end
    print("-----------------------------")
    for k, v in pairs(map) do
        print(k .. "   " .. v)
    end

    print("over")
end

local function test2()
    local list = {}
    table.insert(list, 5)
    table.insert(list, 6)
    table.insert(list, 7)
    table.insert(list, 8)
    table.insert(list, 9)

    for i, v in pairs(list) do
        print(i .. "   " .. v)
    end
    print("-----------------------------")
    for i = 1, 3 do
        local index = math.random(#list)
        print(index .. "   " .. list[index])
        table.remove(list, index)
    end
    print("-----------------------------")
    for i, v in pairs(list) do
        print(i .. "   " .. v)
    end
end

--test1()
test2()