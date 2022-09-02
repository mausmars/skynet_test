local function test()
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

test()