package.cpath = "../../luaclib/?.so;"..package.cpath

local zlib = require "zlib"

local body = "test"
print(body)
-- 压缩
local compress = zlib.deflate()(body, "finish")
print(compress)
-- 解压缩
local uncompress = zlib.inflate()(compress)
print(uncompress)


