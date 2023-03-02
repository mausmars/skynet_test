local function createdKey(x, y)
    return y * 100 + x
end

-- direction 反方向
local function reverse_direction(direction)
    local d = direction + 2
    if d > 4 then
        d = d % 4
    end
    return d
end

--比例随机
local function ratio_random(list)
    local total = 0
    for _, v in pairs(list) do
        total = total + v
    end
    local expectValue = math.random(total)   --期望值
    local range = 0
    for k, v in pairs(list) do
        range = range + v
        if expectValue <= range then
            return k
        end
    end
    return 1
end

--1联通，2末点，3起点
local MarkType = {
    Unicom = 1, -- 1联通
    End = 2, -- 2末点
    Start = 3, -- 3起点
}

--规则类型
local RuleType = {
    General = 1, -- 普通
    Cross = 2, -- 十字策略
}

-- 事件类型
local EventType = {
    START = 0, -- 0-起点        无逻辑
    FIGHT = 101, -- 101-普通战斗   对应 T_Stage 表
    ELITE = 102, -- 102-精英战斗   对应 T_Stage 表
    BOSS = 103, -- 103-boss      对应 T_Stage 表
    HIDE = 104, -- 104-隐藏挑战   对应 T_Stage 表
    BOX = 2, -- 2-宝箱         对应 T_Item 表
    HEAL = 3, -- 3-治疗         对应 T_LairHeal 表
    SUPPORT = 4, -- 4-支援龙       对应 T_LairSupport 表
    TOWER = 5, -- 5-瞭望塔
    EMPTY = 999, -- 999-空点
}

-- 期望值类型
local ExpectCountType = {
    ELITE = 1, -- 精英
    HIDE = 2, -- 隐藏挑战
    TOWER = 3, -- 瞭望塔
    HEAL = 4, -- 医疗
}

local MapPoint = {}

--可联通格子的相对坐标
local relativeCoordinate = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

--防止生产田字格
local checkPointCoordinates = { { { 0, -1 }, { 1, -1 }, { 1, 0 } }, { { 1, 0 }, { 1, 1 }, { 0, 1 } }, { { 0, -1 }, { -1, -1 }, { -1, 0 } }, { { -1, 0 }, { -1, 1 }, { 0, 1 } } }

--预设点相对坐标（针对起始十字格可能导致回路问题）
local presetRelativeCoordinate = { { -1, 0 }, { -2, 0 }, { 1, 0 }, { 2, 0 }, { 0, -1 }, { 0, -2 }, { 0, 1 }, { 0, 2 } }

--基础权重值
local base_weight = 10
--起始权重值
local start_weight = 100

--失败次数
local tatal_fail_count = 10

function MapPoint.new(x, y, mark)
    local data = {}
    data.x = x
    data.y = y
    data.mark = mark                    -- 1联通，2末点，3起点
    data.event_type = EventType.EMPTY   -- 事件类型

    data.repeated_count = 1   -- 点的复用次数（可能被多条路径公用）
    return setmetatable(data, { __index = MapPoint })
end

function MapPoint:createdKey()
    return createdKey(self.x, self.y)
end

--查詢上下文
local FindContext = {}

function FindContext.new()
    local data = {}
    data.usedPoints = {}            --記錄已使用的點
    data.startWeight = { base_weight, base_weight, base_weight, base_weight }    --起始权重
    data.startCount = 0
    data.pathContexts = {}
    data.isSuccess = true
    data.failCount = 0    --失败次数

    data.ruleType = RuleType.General           --1-正常 2-十字

    return setmetatable(data, { __index = FindContext })
end

function FindContext:insertUsedPoint(point, mark)
    local key = createdKey(point[1], point[2])
    local newMapPoint = MapPoint.new(point[1], point[2], mark)
    self.usedPoints[key] = newMapPoint
    --print("插入 usedPoints key=" .. key .. " mark=" .. mark)
    return newMapPoint
end

function FindContext:usedPointSize()
    return #self.usedPoints
end

function FindContext:findUsedPoint(point)
    local key = createdKey(point[1], point[2])
    return self.usedPoints[key]
end

--随机朝向，
function FindContext:randomPathStartDirection()
    if self.ruleType == RuleType.Cross then
        --起始十字规则
        local direction = ratio_random(self.startWeight)
        --print("###### direction=" .. direction)
        self.startCount = self.startCount + 1
        if self.startCount < 4 then
            self.startWeight[direction] = 0
        else
            self.startWeight = { base_weight, base_weight, base_weight, base_weight }
        end
        return direction
    else
        self.startWeight = { base_weight, base_weight, base_weight, base_weight }
        --默认规则
        local direction = math.random(100) % 4 + 1
        return direction
    end
end

--路徑下文
local PathContext = {}

function PathContext.new(findContext, direction)
    local data = {}
    data.findContext = findContext
    data.path = {}      --记录路径
    data.pathSize = 0   --路径长度
    data.step = 0       --记录步长（新加入的点才算）
    data.weight = { base_weight, base_weight, base_weight, base_weight }       --方向权重
    data.startDirection = direction    --起始方向

    data.weight[direction] = start_weight     --加大起始方向的权重

    data.end_point_key = 0      --末点key
    return setmetatable(data, { __index = PathContext })
end

--需要提前走的点
function PathContext:initPath(startPoint)
    local rc = relativeCoordinate[self.startDirection]
    local newPoint = { startPoint[1] + rc[1], startPoint[2] + rc[2] }

    local mp = self.findContext:findUsedPoint(newPoint)
    if mp == nil then
        self.findContext:insertUsedPoint(newPoint, 1)
        self:insertPoint(newPoint, 1)
    else
        mp.repeated_count = mp.repeated_count + 1
        self:insertPoint(newPoint, 0)
    end

    newPoint = { newPoint[1] + rc[1], newPoint[2] + rc[2] }
    mp = self.findContext:findUsedPoint(newPoint)
    if mp == nil then
        self.findContext:insertUsedPoint(newPoint, 1)
        self:insertPoint(newPoint, 1)
    else
        mp.repeated_count = mp.repeated_count + 1
        self:insertPoint(newPoint, 0)
    end

    return newPoint
end

--增加权重值
function PathContext:increase_weight(direction)
    --取反向
    local rd = reverse_direction(direction)
    for k, v in pairs(self.weight) do
        if k ~= rd then
            self.weight[k] = v + base_weight
        end
    end
end

--随机朝向，
function PathContext:randomDirection()
    return ratio_random(self.weight)
end

function PathContext:contain(point)
    local key = createdKey(point[1], point[2])
    return self.path[key] ~= nil
end

function PathContext:containByKey(key)
    return self.path[key] ~= nil
end

function PathContext:insertPoint(point, isNew)
    local key = createdKey(point[1], point[2])
    self.path[key] = isNew

    if isNew > 0 then
        self.step = self.step + 1
    end
    self.pathSize = self.pathSize + 1
    --print("插入PathContext key=" .. key)
    return key
end

--回滾數據
function PathContext:rollback()
    for k, v in pairs(self.path) do
        if v > 0 then
            self.findContext.usedPoints[k] = nil
        end
    end
end

local MapCreater = {}

function MapCreater.new(mapSize, startPoint)
    local data = {}
    data.mapSize = mapSize              -- 地图大小
    data.startPoint = startPoint        -- 起点
    data.presetPoint = {}               -- 预设点
    return setmetatable(data, { __index = MapCreater })
end

function MapCreater:init()
    for _, rc in pairs(presetRelativeCoordinate) do
        local key = createdKey(self.startPoint[1] + rc[1], self.startPoint[2] + rc[2])
        self.presetPoint[key] = 1
    end
end

--当前坐标方向上的坐标
function MapCreater:coordinate(point, direction)
    local rc = relativeCoordinate[direction]
    return { point[1] + rc[1], point[2] + rc[2] }
end

function MapCreater:isPresetPoint(point)
    local key = createdKey(point[1], point[2])
    return self.presetPoint[key] ~= nil
end

--检查非法点，超出地图
function MapCreater:checkIllegal(point)
    return point[1] >= 1 and point[2] >= 1 and point[1] <= self.mapSize[1] and point[2] <= self.mapSize[2]
end

function MapCreater:checkPointAround(point, findContext)
    for i = 1, #checkPointCoordinates do
        local cpcs = checkPointCoordinates[i]
        local size = 0
        for k = 1, #cpcs do
            local x = point[1] + cpcs[k][1]
            local y = point[2] + cpcs[k][2]

            local usedPoint = findContext:findUsedPoint({ x, y })
            if usedPoint ~= nil then
                size = size + 1
            end
        end
        if (size == 3) then
            return false
        end
    end
    return true
end

--检查新点周围的点，不能大于2个
function MapCreater:checkNewPointAround(point, findContext)
    local size = 0
    for _, rc in pairs(relativeCoordinate) do
        local x = point[1] + rc[1]
        local y = point[2] + rc[2]
        local usedPoint = findContext:findUsedPoint({ x, y })
        if usedPoint ~= nil then
            size = size + 1
        end
        if (size > 1) then
            return false
        end
    end
    return true
end

function MapCreater:checkNewPointAroundPresetPoint(point, pathContext)
    for _, rc in pairs(relativeCoordinate) do
        local p = { point[1] + rc[1], point[2] + rc[2] }
        if (not pathContext:contain(p)) and self:isPresetPoint(p) then
            return false
        end
    end
    return true
end

function MapCreater:checkPoint(point, pathContext)
    if not self:checkIllegal(point) then
        --print("取点失败 地图越界 "..point[1]..","..point[2])
        return false
    end
    local usedPoint = pathContext.findContext:findUsedPoint(point)
    if usedPoint == nil and (not self:checkNewPointAround(point, pathContext.findContext)) then
        --如果是新点，周围的旧点不能大于2个
        return false
    end
    if pathContext.findContext.ruleType == RuleType.Cross then
        -- 十字规则才跳过预设点
        if not self:checkNewPointAroundPresetPoint(point, pathContext) then
            --新点周围预设点
            return false
        end
    end
    if pathContext:contain(point) then
        --print("取点失败 当前路径包括该点 "..point[1]..","..point[2])
        return false
    end
    if not self:checkPointAround(point, pathContext.findContext) then
        --print("取点失败 点周围不符合要求 "..point[1]..","..point[2])
        return false
    end
    return true
end

--随机一个可用点
function MapCreater:randomNextMapPoint(point, pathContext)
    --隨機一個起始方向
    local direction = pathContext:randomDirection()

    for i = 1, 4 do
        local newPoint = self:coordinate(point, direction)
        --print("找point周圍4個點 newPoint="..newPoint[1]..","..newPoint[2])

        if self:checkPoint(newPoint, pathContext) then
            local mp = pathContext.findContext:findUsedPoint(newPoint)
            if mp == nil then
                local newMapPoint = pathContext.findContext:insertUsedPoint(newPoint, 1)
                --修改朝向权重
                pathContext:increase_weight(direction)
                return newMapPoint, true
            elseif mp.mark == MarkType.Unicom then
                --修改朝向权重
                pathContext:increase_weight(direction)
                return mp, false
            end
        end

        --新选点的周围
        direction = direction + 1
        if direction > 4 then
            direction = 1
        end
    end
    return nil, false
end

function MapCreater:findPath2(findContext, times, expectStep, totalStep)
    local nextPoint = { self.startPoint[1], self.startPoint[2] }

    --随机path的起始方向
    local direction = findContext:randomPathStartDirection()
    --print("--- 随机 pathContext 起始方向 --- " .. direction)
    local pathContext = PathContext.new(findContext, direction)
    pathContext:insertPoint(self.startPoint, 0)

    if findContext.ruleType == RuleType.Cross then
        --选定方向朝固定方向走2个格
        nextPoint = pathContext:initPath(self.startPoint)
    end

    local isFail = false
    while (true) do
        --print("findPath " .. nextPoint[1] .. "," .. nextPoint[2])
        local newMapPoint, isNewMapPoint = self:randomNextMapPoint(nextPoint, pathContext)
        if newMapPoint == nil then
            --print("!!!!!!!!!!!!!! 没有可用的节点 需要重新找 回滚数据 !!!!!!!!!!!!!!!!!!!!")
            pathContext:rollback()  --回滚数据
            isFail = true

            findContext.failCount = findContext.failCount + 1
            if findContext.failCount > tatal_fail_count then
                findContext.isSuccess = false  --查询失败
                return nil
            end
            break
        end
        local key = pathContext:insertPoint({ newMapPoint.x, newMapPoint.y }, isNewMapPoint and 1 or 0)

        if pathContext.step >= expectStep then
            newMapPoint.mark = MarkType.End
            pathContext.end_point_key = key
            --print("### 达到期望步数 修改mark为2 " .. newMapPoint.x .. "," .. newMapPoint.y)
            break
        end
        if findContext:usedPointSize() > totalStep then
            newMapPoint.mark = MarkType.End
            pathContext.end_point_key = key
            --print("### 达到总步数 修改mark为2 " .. newMapPoint.x .. "," .. newMapPoint.y)
            break
        end

        nextPoint[1] = newMapPoint.x
        nextPoint[2] = newMapPoint.y
    end

    if (isFail) then
        return self:findPath2(findContext, times, expectStep, totalStep)
    end
    return pathContext
end

--查找路径
function MapCreater:findPath(findContext, times, expectStep, totalStep)
    --print("--- 开始查询路径 startPoint [" .. startPoint[1] .. " " .. startPoint[2] .. "] ---")
    return self:findPath2(findContext, times, expectStep, totalStep)
end

function MapCreater:findPaths(endCount, totalStep, fight_random_range, recovery_random_range, expect_counts)
    --平均步数
    local averageStep = totalStep // endCount
    local remainder = totalStep % endCount

    --print("开始查找路径 startPoint=" .. startPoint[1] .. "," .. startPoint[2] .. " totalStep=" .. totalStep .. " endCount=" .. endCount .. " averageStep=" .. averageStep)

    local findContext = FindContext.new()
    if totalStep > 12 then
        findContext.ruleType = RuleType.Cross
    end
    findContext:insertUsedPoint(self.startPoint, MarkType.Start)   --插入起点

    --這裏可以修改期望次數
    for times = 1, endCount do
        local expectStep = averageStep
        if times <= remainder then
            expectStep = expectStep + 1
        end
        --查找路径
        local pathContext = self:findPath(findContext, times, expectStep, totalStep)
        table.insert(findContext.pathContexts, pathContext)
    end

    self:printPoints(findContext)

    -- 设置事件类型
    self:set_event_type(findContext, fight_random_range, recovery_random_range, expect_counts)

    --if findContext.isSuccess then
    --打印地图
    self:printMap(findContext)
    --end

    return findContext
end

function MapCreater:relativeCoordinate()
    return relativeCoordinate
end

function MapCreater:createdKey(point)
    return createdKey(point[1], point[2])
end

-- 相连的点
function MapCreater:connect_point_by_xy(x, y, path, points)
    for _, v in pairs(self:relativeCoordinate()) do
        local p = { x + v[1], y + v[2] }
        local k = self:createdKey(p)
        if path[k] ~= nil and points[k] == nil then
            points[k] = 0
            return k
        end
    end
    return nil
end

-- 相连的点
function MapCreater:connect_point_by_point(point, paths, points)
    local x = point % 100
    local y = point // 100
    return self:connect_point_by_xy(x, y, paths, points)
end

-- 设置事件类型
function MapCreater:set_event_type(findContext, fight_random_range, recovery_random_range, expectcounts)
    --查找路徑最長的通路
    local maxCountPath = nil
    for _, pc in pairs(findContext.pathContexts) do
        if maxCountPath == nil then
            maxCountPath = pc
        else
            if maxCountPath.pathSize < pc.pathSize then
                maxCountPath = pc
            end
        end
    end

    local counts = { 0, 0, 0, 0 }
    for _, pc in pairs(findContext.pathContexts) do
        local points = {} --防止放回走

        local pointKey = createdKey(self.startPoint[1], self.startPoint[2])
        points[pointKey] = 0
        local mp = findContext.usedPoints[pointKey]
        mp.event_type = EventType.START

        local fight_step = math.random(fight_random_range[1], fight_random_range[2])
        local fight_interval = 0
        local recovery_step = math.random(recovery_random_range[1], recovery_random_range[2])
        local index = 0

        while (true) do
            local k = self:connect_point_by_point(pointKey, pc.path, points)
            if k ~= nil then
                pointKey = k
            else
                break
            end
            index = index + 1
            fight_interval = fight_interval + 1
            if fight_interval == fight_step + 1 then
                local mp = findContext.usedPoints[pointKey]
                if mp.event_type == EventType.EMPTY then
                    mp.event_type = EventType.FIGHT
                end
                fight_step = math.random(fight_random_range[1], fight_random_range[2])
                fight_interval = 0
            end

            if index == pc.pathSize - (recovery_step) - 2 then
                if counts[ExpectCountType.HEAL] < expectcounts[ExpectCountType.HEAL] then
                    local mp = findContext.usedPoints[pointKey]
                    mp.event_type = EventType.HEAL
                    counts[ExpectCountType.HEAL] = counts[ExpectCountType.HEAL] + 1
                end
            end
        end
        -- 末点
        local end_point = findContext.usedPoints[pointKey]
        if maxCountPath == pc then
            end_point.event_type = EventType.BOSS
        elseif counts[ExpectCountType.HIDE] < expectcounts[ExpectCountType.HIDE] then
            end_point.event_type = EventType.HIDE
            counts[ExpectCountType.HIDE] = counts[ExpectCountType.HIDE] + 1
        elseif counts[ExpectCountType.TOWER] < expectcounts[ExpectCountType.TOWER] then
            end_point.event_type = EventType.TOWER
            counts[ExpectCountType.TOWER] = counts[ExpectCountType.TOWER] + 1
        elseif counts[ExpectCountType.ELITE] < expectcounts[ExpectCountType.ELITE] then
            end_point.event_type = EventType.ELITE
            counts[ExpectCountType.ELITE] = counts[ExpectCountType.ELITE] + 1
        else
            end_point.event_type = EventType.BOX
        end
    end
end

function MapCreater:printMap(findContext)
    print("-------------------------------------------")
    --查找路徑最長的通路
    local maxCountPath = nil
    for k, pc in pairs(findContext.pathContexts) do
        if maxCountPath == nil then
            maxCountPath = pc
        else
            if maxCountPath.pathSize < pc.pathSize then
                maxCountPath = pc
            end
        end
    end

    print("[#]EMPTY [S]START [@]FIGHT [B]boss关 [C]HIDE [E]ELITE [T]TOWER [H]HEAL [X]BOX")
    if findContext.isSuccess then
        print("Success!")
    else
        print("Fail!")
    end
    for y = 1, self.mapSize[2] do
        local row = ""
        for x = 1, self.mapSize[1] do
            local k = createdKey(x, y)
            local p = findContext.usedPoints[k]
            if p == nil then
                row = row .. " "
            elseif p.event_type == EventType.EMPTY then
                row = row .. "#"
            elseif p.event_type == EventType.BOSS then
                row = row .. "B"
            elseif p.event_type == EventType.ELITE then
                row = row .. "E"
            elseif p.event_type == EventType.START then
                row = row .. "S"
            elseif p.event_type == EventType.TOWER then
                row = row .. "T"
            elseif p.event_type == EventType.FIGHT then
                row = row .. "@"
            elseif p.event_type == EventType.HEAL then
                row = row .. "H"
            elseif p.event_type == EventType.HIDE then
                row = row .. "C"
            elseif p.event_type == EventType.BOX then
                row = row .. "X"
            else
                row = row .. "U"
            end
        end
        print(row)
    end
    --self:printPoints(findContext)
end

function MapCreater:printPoints(findContext)
    print("---------------------------------")
    for k, v in pairs(findContext.usedPoints) do
        print("打印地图点 " .. k .. " [" .. v.x .. "," .. v.y .. "] mark=" .. v.mark .. " repeated_count=" .. v.repeated_count)
    end

    for k, pc in pairs(findContext.pathContexts) do
        print("--- path --")
        for k, v in pairs(pc.path) do
            print("" .. k .. " " .. v)
        end
    end
end

local function init()
    --初始随机数
    math.randomseed(os.time())
end
--初始化
init()

local function test()
    local endCount = 8                  -- x个结束点
    local totalStep = 170               -- x个格子
    local startPoint = { 15, 15 }       -- 起点坐标
    local mapSize = { 30, 30 }          -- 地图大小
    local fight_random_range = { 2, 4 }      -- 普通关卡间隔随机区间
    local recovery_random_range = { 2, 5 }   -- 恢复池倒数格数随机区间
    local expect_counts = { 2, 1, 1, 6 }        -- 期望值（精英|隐藏挑战|瞭望台|治疗）

    local totalCount = 1

    local totalTime = 0
    local failCount = 0

    local mapCreater = MapCreater.new(mapSize, startPoint)
    mapCreater:init()

    local t0 = os.clock()
    for i = 1, totalCount do
        --print("--------------------------------------------------------------------------------------")
        local findContext = mapCreater:findPaths(endCount, totalStep, fight_random_range, recovery_random_range, expect_counts)
        if not findContext.isSuccess then
            failCount = failCount + 1
        end
    end
    local t1 = os.clock()
    --print("used time: "..t1-t0.." s")
    totalTime = (t1 - t0)
    print("used totalCount=" .. totalCount .. " totalTime=" .. totalTime .. "s  failCount=" .. failCount)
end

test()
