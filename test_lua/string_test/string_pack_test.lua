local unpack = string.unpack
local pack = string.pack

local function test1()
    --字节符 b 打包解包 pack(“b”,str） unpack(“b”,str）
    local str1 = pack(">b", -128) --最小支持 -128
    local str2 = pack("<b", 127) --最大支持 127

    --如果把 pack("b",127) 改为 pack("b",128)，就会出现下面的错误
    --bad argument #2 to 'pack' (integer overflow)，意思是pack的第二个参数整型溢出了
    print(unpack(">b", str1)) --输出-128  2 ，这个2表示下一个字节的位置
    print(unpack("<b", str2)) --输出127  2 ，这个2表示下一个字节的位置
end

local function test2()
    local str1 = pack("B", 0) --最小支持 0
    local str2 = pack("B", 255) --最大支持 255
    --如果改为 pack("B",-1) 或者 pack("B",256)，就会出现下面的错误
    --bad argument #2 to 'pack' (unsigned overflow)，意思是pack的第二个参数类型溢出了
    print(unpack("B", str1)) --输出0  2 ，这个2表示下一个字节的位置
    print(unpack("B", str2)) --输出255  2 ，这个2表示下一个字节的位置
end

local function test3()
    --H 表示short，在32位平台下如windows(32位)中一般为16位
    local str1 = pack("H", 0) --最小支持 0
    local str2 = pack("H", 65535) --最大支持 65535
    --如果改为 pack("H",-1) 或者 pack("H",65536)，就会出现下面的错误
    --bad argument #2 to 'pack' (unsigned overflow)，意思是pack的第二个参数类型溢出了
    print(unpack("H", str1)) --输出0  3 ，这个3表示下一个short的位置，每个short占2字节
    print(unpack("H", str2)) --输出65535  3 ，这个3表示下一个short的位置
end

local function test4()
    local str1 = pack("h", -32768) --最小支持 -32768
    local str2 = pack("h", 32767) --最大支持 32767
    --如果改为 pack("H",-32769) 或者 pack("H",32768)，就会出现下面的错误
    --bad argument #2 to 'pack' (integer overflow)，意思是pack的第二个参数溢出了
    print(unpack("h", str1)) --输出-32768  3 ，这个3表示下一个short的位置，每个short占2字节
    print(unpack("h", str2)) -- 32767  3 ，这个3表示下一个short的位置
end

local function test5()
    -- I默认是占4字节，但是可以给I指定字节数，如 I2 就是占2字节,I3占3字节
    local str1 = pack("I", 0) --最小支持 0
    local str2 = pack("I", 4294967295) --最大支持 4294967295
    --如果改为 pack("I",-1) 或者 pack("I",4294967296)，就会出现下面的错误
    --bad argument #2 to 'pack' (unsigned overflow)，意思是pack的第二个参数类型溢出了
    print(unpack("I", str1)) --输出0  5 ，这个5表示下一个字节的位置,I 默认占4字节
    print(unpack("I", str2)) --输出4294967295  5 ，这个5表示下一个字节的位置

    local str3 = pack("I2", 0) --最小支持 0
    local str4 = pack("I2", 65535) --最大支持 4294967295
    print(unpack("I2", str3)) --输出0  3 ，这个3表示下一个字节的位置,I2 占2字节
    print(unpack("I2", str4)) --输出4294967295  3 ，这个3表示下一个字节的位置

    local str5 = pack("I3", 0) --最小支持 0
    local str6 = pack("I3", 16777215) --最大支持 16777215
    print(unpack("I3", str5)) --输出 0  4 ，这个4表示下一个字节的位置,I3 占3字节
    print(unpack("I3", str6)) --输出 16777215  4 ，这个4表示下一个字节的位置
end

local function test6()
    -- c 表示一个字节
    local str1 = pack("c1",'a') --表示最大支持1个字节的字符
    print('#str1',#str1) --输出 #str1	1
    --如果改为 pack("c1",'aa') ,就会出现如下的错误
    --bad argument #2 to 'pack' (string longer than given size)
    local str2 = pack("c5",'a') --表示最大支持5个字节的字符
    print('#str2',#str2) --输出 #str2	5

    print(unpack("c1", str1)) --输出a  2 ，这个2表示下一个字节的位置,c1 占1字节
    print(unpack("c5", str2)) --输出1  6 ，这个6表示下一个字节的位置,c5 占5字节
end

local function test7()
    -- s,可指定头部占用字节数，默认占8字节
    local temp1 = pack("s",'a')
    print(unpack('s', temp1))
    --输出 a    10,这个10表示下一个字符的位置

    local temp2 = pack("s",'abc')
    print(unpack('s', temp2))
    --输出 abc	12,这个12表示下一个字符的位置

    local temp3 = pack("ss",'abc','efg')
    print(unpack('s', temp3, 12))
    --输出 efg	23,这个23表示下一个字符的位置

    -- s 默认头部占8字节，s1表示头部占1字节、s2表示头部占2字节

    local temp4 = pack("s2",'abc')
    print(unpack('s2', temp4))
    --输出 abc    6,这个6表示下一个字符的位置

    local temp5 = pack("s2s2",'abc','efg')
    print(unpack('s2', temp5, 6))
    --输出 efg	11,这个11表示下一个字符的位置
end

test1()
print("-----------------")
test2()
print("-----------------")
test3()
print("-----------------")
test4()
print("-----------------")
test5()
print("-----------------")
test6()
print("-----------------")
test7()
