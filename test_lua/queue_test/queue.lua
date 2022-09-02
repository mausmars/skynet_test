local Queue = {}

function Queue.new()
    local data = {}
    data.first = 0
    data.last = -1
    data.n = 0
    return setmetatable(data, { __index = Queue })
end

function Queue:lpush(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
    self.n = self.n + 1
end

function Queue:rpush(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
    self.n = self.n + 1
end

function Queue:lpop()
    local first = self.first
    if first > self.last then
        return nil, true
    end
    local value = self[first]
    self[first] = nil        -- to allow garbage collection
    self.first = first + 1
    self.n = self.n - 1
    return value
end

function Queue:rpop()
    local last = self.last
    if self.first > last then
        return nil, true
    end
    local value = self[last]
    self[last] = nil         -- to allow garbage collection
    self.last = last - 1
    self.n = self.n - 1
    return value
end

function Queue:size()
    return self.n
end

return Queue