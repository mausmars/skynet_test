local TestClass = {}

function TestClass.new()
    local data = {}
    data.a = 1
    return setmetatable(data, { __index = TestClass })
end

local test = TestClass.new()
print("test.a=" .. test.a)