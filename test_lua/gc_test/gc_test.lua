local gc_times = 0

local function data_gc(self)
    --print("data_gc", self)
    gc_times = gc_times + 1
end

local Data = {}

function Data.new(name, age)
    local data = {}
    data.name = name
    data.age = age
    data.members = {}
    return setmetatable(data, { __index = Data, __gc = data_gc })
end

local function create_data()
    local data = Data.new("test", 10)
    for i = 1, 1000 do
        table.insert(data.members, { name = "member_" .. tostring(i), age = i })
    end
    return data
end

local function test()
    print("gc count ", collectgarbage("count"))
    for i = 1, 100 do
        local data = create_data()
    end
    print("gc count ", collectgarbage("count"))
    print("gc collect ", collectgarbage("collect"))

    print("gc gc_times ", gc_times)

    print("gc count ", collectgarbage("count"))

end

test()