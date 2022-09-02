local util = {}

function util:sum(...)
    local sum = 0
    for _, v in ipairs { ... } do
        sum = sum + v
    end
    --print("test " .. self.test)
    return sum, ...
end

return util