local Person = require("Person")

--local Student = {}
local Student = setmetatable({}, { __index = Person })
Student.super = Person

function Student.new(name, score)
    local data = Person.new(name)
    data.score = score
    data.a = 1
    return setmetatable(data, { __index = Student })
end

function Student:print1()
    self.super.print1(self)
    print("score is ", self.score)
    print("self.a is ", self.a)
end

function Person:print3()
    print("print3 name is ", self.name)
end

return Student