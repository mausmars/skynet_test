CC ?= gcc
CFLAGS = -g -O2 -Wall -I$(LUA_INC)
SHARED := -fPIC --shared

TARGET = mylib.so
LUA_CLIB_PATH = clib

# 引入lua头文件 github 下载的lua5.3.6版本
LUA_INC ?= /mnt/e/work/git_src/lua

start: $(TARGET)

$(TARGET) : mylib.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)

clean:
	rm -fr $(TARGET)


