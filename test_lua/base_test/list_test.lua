local function test()
    local list = {}
    table.insert(list, 1)
    table.insert(list, 2)
    table.insert(list, 3)
    table.insert(list, 4)
    table.insert(list, 5)

    for i = 1, 2 do
        local index = math.random(1, #list)
        print(list[index])
        table.remove(list, index)
    end
    print("-------------------------------")
    for i = 1, #list do
        print(list[i])
    end

end

test()

