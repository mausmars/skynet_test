local Person = {}

function Person.new(name)
    local data = {}
    data.name = name
    return setmetatable(data, { __index = Person })
end

function Person:print1()
    print("print1 name is ", self.name)
end

function Person:print2()
    print("print2 name is ", self.name)
end

return Person