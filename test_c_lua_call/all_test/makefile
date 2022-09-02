CC = gcc
CFLAGS = -g -O2 -Wall
SHARED := -fPIC --shared

TARGET1 = ctest.so
TARGET2 = main

# 引入lua头文件 github 下载的lua5.3.6版本
LUA_INC = /mnt/e/work/git_src/lua

start: $(TARGET1) $(TARGET2)

$(TARGET1) : ctest.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) -I$(LUA_INC) $(SHARED) $^ -o $@ -lpthread

$(TARGET2) : container.c | $(LUA_CLIB_PATH)
	$(CC) -I$(LUA_INC) -L$(LUA_INC) -static -llua $^ -o $@

clean:
	rm -fr $(TARGET1) && rm -fr $(TARGET2)
