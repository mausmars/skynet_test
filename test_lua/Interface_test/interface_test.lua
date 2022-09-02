local romt = {}
romt.__call = function(self, target)
    if target then
        return BehaviorObject.extend(target)
    end
    printError("ro() - invalid target")
end
setmetatable(ro, romt)



function BasePanel:ctor(options)
    ro(self):addBehavior("Logic.behaviors.BindableBehavior"):exportMethods()
end


