package.cpath = "../../luaclib/?.so;" .. package.cpath

local cjson = require "cjson"
--cjson.encode_empty_table_as_object(true)
--local empty_arr = setmetatable({}, cjson.empty_array_mt)

local function sub_bean()
    local data = {}
    data.a = 1
    data.b = "b"
    data.c = { k = "v" }
    data.d = {}

    --some_array = json.empty_array
    data.e = {}
    table.insert(data.e, 1)

    return data
end

local function bean()
    local data = {}
    data.sub_bean_str = cjson.encode(sub_bean())
    data.sub_bean = sub_bean()
    return data
end

local function test()
    print("cjson name ", cjson._NAME)
    print("cjson version ", cjson._VERSION)

    print("{null} ", cjson.encode({ 'null' }))

    cjson.encode_sparse_array(false, 0)
    print(cjson.encode({ [3] = "data" }))
    print("encode_sparse_array ", cjson.encode_sparse_array(true, 2, 3))

    local content = cjson.encode(bean())
    print(content)
end

local function test2()
    local t = cjson.decode("{\"code\":\"2\",\"msg\":\"batch data into json array error\"}")
    print(t.code)
end

test()
test2()
