local function test()
    local mytable = { "apple", "orange", "banana" }
    print("gc count ", collectgarbage("count"))
    mytable = nil
    print("gc count ", collectgarbage("count"))
    print("gc collect ", collectgarbage("collect"))
    print("gc count ", collectgarbage("count"))

end

test()