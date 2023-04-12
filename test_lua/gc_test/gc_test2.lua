local ref

local function object_new()
    local o = {}
    return setmetatable(o,{
        __gc = function (self)
            ref = self
            --需要再标记一次需要调用终结器，否则终结器不会再被调用
            setmetatable(ref,{ __gc = function (self)
                print("object gc",self)
            end})
            print("object relive",self)
        end
    })
end


local object = object_new()
object = nil
collectgarbage("collect")
ref = nil
collectgarbage("collect")
print("ok")