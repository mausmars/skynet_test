local Student = require("Student")

local function test()
    local s = Student.new("Tony", 98)
    s:print1()
    s:print2()
    s:print3()
end

test()