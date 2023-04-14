--总之就是test继承了event的一个方法，只要以函数形式调用test就会调用那个方法，传入的self是test自身的表，不是元表event的表，然后第二个参数则是传入的参数

local function test1()
    print("--- test1 ---")
    local event = {}
    event.__call = function(self, index)
        print("index=", index)
    end

    local test = {}
    setmetatable(test, event)
    test(3)
end

local function test2()
    print("--- test2 ---")
    local event = {}
    event.__call = function(self, index)
        print("self.a=", self.a)
        print("index=", index)
    end

    local test = { a = 1 }
    setmetatable(test, event)
    test(3)
end

local function test3()
    print("--- test3 ---")
    local event = { a = 1 }
    event.__call = function(self, index)
        print("self.a=", self.a)
        print("index=", index)
    end

    local test = {}
    setmetatable(test, event)
    test(3)
end

local function test4()
    print("--- test4 ---")
    local event = {}
    event.__call = function(self, index)
        print("self.a=", self.a)
        return index + 1
    end

    local test = {}
    setmetatable(test, event)
    print("ret=", test(4))
end

test1()
test2()
test3()
test4()