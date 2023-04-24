local function test()
    local str = "abc \r\n"

    local last_char = string.sub(str, string.len(str))

    if last_char == "\n" then
        print("last_char == n")
    elseif last_char == "\r" then
        print("last_char == r")
    end
end

test()