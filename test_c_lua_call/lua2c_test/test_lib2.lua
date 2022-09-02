package.cpath = "./createlib2/?.so"     --so搜寻路劲
local ctest = require "ctest"           -- 对应luaopen_test中的myLualib

local function test()
    local a = ctest.new(1000)
    print(a)                        --> userdata: 0x8064d48
    print("size=" .. ctest.size(a))
    for i = 1, 1000 do
        ctest.set(a, i, i)
    end
    print("get v=" .. ctest.get(a, 10))
end

test()