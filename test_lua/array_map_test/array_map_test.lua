local function test()
    local total = 4
    local array = {}
    for i = 1, total do
        table.insert(array, 100 + i)
    end
    local map = {}
    for i = 1, total do
        map[i] = 100 + i
    end

    for i, v in pairs(array) do
        print(i, v)
    end
    print("-----------------------")
    for k, v in pairs(map) do
        print(k, v)
    end
end

test()