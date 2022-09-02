package.cpath = "./?.so" --so搜寻路劲
local c = require("test")

local UserMgr = {}

function UserMgr.new()
    local data = {}
    data.users = {}
    return setmetatable(data, { __index = UserMgr })
end

function UserMgr:insert_user(user)
    self.user[user.name] = user
end

local user_mgr = UserMgr.new()

local function create_user_info(name, age, city, zipcode)
    local data = {}
    data.name = name
    data.age = age
    data.addr = {}
    data.addr.city = city
    data.addr.zipcode = zipcode
    return data
end

local function start_test()
    print("start_test")
    local user_1 = create_user_info("mm_1", 18, "china", 100043)
    --c.create_user(user_1, user_mgr)
end
