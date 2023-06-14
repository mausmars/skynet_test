local function test()
    local map = {}
    for i = 99, 1, -1 do
        map[i] = i
    end
    for k, v in pairs(map) do
        print(k .. "_" .. v)
        map[k] = k * 10
    end
    print("---------------------")
    for k, v in pairs(map) do
        print(k .. "_" .. v)
    end
end

test()