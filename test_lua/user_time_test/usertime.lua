package.cpath = "./?.so" --so搜寻路劲
local utime = require "usertime"

local microsecond = utime.getmicrosecond()
local millisecond = utime.getmillisecond()

print('microsecond',microsecond)
print('millisecond',millisecond)