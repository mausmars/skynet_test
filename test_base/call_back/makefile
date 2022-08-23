CC ?= gcc
CFLAGS = -g -O2 -Wall -I$(LUA_INC)
SHARED := -fPIC --shared

TARGET = cb.so

# 引入lua头文件
LUA_INC = ../../3rd/lua

start: $(TARGET)

$(TARGET) : cb.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -lpthread && cp $(TARGET) ../../luaclib && rm -fr $(TARGET)

clean:
	rm -fr $(TARGET)
