CC ?= gcc
# 引入lua头文件
LUA_INC ?= /mnt/e/work/git_src/lua
CFLAGS = -I$(LUA_INC)

LIB_INC ?= /usr/local/include/luajit-2.1
LIB = -L$(LIB_INC)

TARGET = c-lua-struct

start: $(TARGET)

$(TARGET) : c-lua-struct.c
	$(CC) $(CFLAGS) $(LIB) $^ -o $@

clean:
	rm -fr $(TARGET)

