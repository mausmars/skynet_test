local function test()
    local v1 = 1 << 1
    local v2 = 1 << 6

    local v = v1 + v2
    print("v=", v)

    local r1 = v & v1
    local r2 = v & v2

    local r3 = v & (1 << 2)
    local r4 = v & (1 << 3)

    print("r1=", r1)
    print("r2=", r2)
    print("r3=", r3)
    print("r4=", r4)
end

test()