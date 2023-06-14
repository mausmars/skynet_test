local function test()
    local enemys = {}
    for i = 1, 10 do
        table.insert(enemys, { battle_force = i * 100 })
    end

    local total_battle_force = 500
    local list = {}
    for _, enemy in pairs(enemys) do
        local dv = math.abs(total_battle_force - enemy.battle_force)
        table.insert(list, { value = dv, enemy = enemy })
    end
    table.sort(list, function(a, b)
        return a.value < b.value
    end)
    local new_enemys = {}
    local lash_index = #list > 5 and 5 or #list
    for i = 1, lash_index do
        table.insert(new_enemys, list[i].enemy)
    end

    print("------------------------------")
    for _, new_enemy in pairs(new_enemys) do
        print(new_enemy.battle_force)
    end
end

test()

