local function test()
    print "Who are you? "
    local who = io.read()

    print "Where do you live? "
    local where = io.read()

    local title = who .. " from " .. where

    print(title)
    -- rep 替换字符
    print(string.rep("-", string.len(title)))
end

test()