CC ?= gcc
CFLAGS = -g -O2 -Wall -I$(LUA_INC) -I$(ZK_INC) -L$(ZK_LIB)
SHARED := -fPIC --shared

TARGET = zk_async_client.so

# 引入lua头文件
LUA_INC = ../../3rd/lua
ZK_INC = /mnt/e/work/git_src/zookeeper/zookeeper-client/zookeeper-client-c/include
ZK_LIB = /mnt/e/work/git_src/zookeeper/zookeeper-client/zookeeper-client-c/.lib

start: $(TARGET)

$(TARGET) : zk_async_client.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -lzookeeper_mt && cp $(TARGET) ../../luaclib && rm -fr $(TARGET)

clean:
	rm -fr $(TARGET)
