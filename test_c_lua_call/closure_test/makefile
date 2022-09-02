CC ?= gcc
CFLAGS = -g -O2 -Wall -I$(LUA_INC)
SHARED := -fPIC --shared

TARGET = closure.so

# 引入lua头文件
LUA_INC = /software/lua

start: $(TARGET)

$(TARGET) : closure.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -lpthread

clean:
	rm -fr $(TARGET)
