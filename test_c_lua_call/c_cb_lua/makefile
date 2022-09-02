CC ?= gcc
CFLAGS = -g -O2 -Wall -I$(LUA_INC)
SHARED := -fPIC --shared

TARGET = cb.so

# 引入lua头文件 github 下载的lua5.3.6版本
LUA_INC = /mnt/e/work/git_src/lua

start: $(TARGET)

$(TARGET) : cb.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -lpthread

clean:
	rm -fr $(TARGET)
