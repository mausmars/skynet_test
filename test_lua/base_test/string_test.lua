local function test()
    local Check_Version_Template = "version:"

    local str = nil
    --local str = ""
    --local str = "version:ddddddddd"

    local start_index, end_index = string.find(str, "^"..Check_Version_Template)
    print(start_index, end_index)
    if start_index ~= nil then
        print(string.sub(str, end_index + 1, -1))
    end
    print(string.sub(str, 1, #Check_Version_Template))
end

test()

