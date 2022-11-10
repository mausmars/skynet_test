##### Build defaults #####
LUA_VERSION =       5.3
PROJROOT =          ../
TARGET =            $(PROJROOT)luaclib/cjson.so
PREFIX =            /usr/local
#CFLAGS =            -g -Wall -pedantic -fno-inline
CFLAGS =            -O3 -Wall -pedantic -DNDEBUG
CJSON_CFLAGS =      -fpic
CJSON_LDFLAGS =     -shared
LUA_INCLUDE_DIR =   $(PROJROOT)lua # $(PREFIX)/include
LUA_CMODULE_DIR =   $(PREFIX)/lib/lua/$(LUA_VERSION)
LUA_MODULE_DIR =    $(PREFIX)/share/lua/$(LUA_VERSION)
LUA_BIN_DIR =       $(PREFIX)/bin

.PHONY : all linux mingw

all : linux

linux :
	gcc -g -Wall -fPIC --shared -o snapshot.so snapshot.c -I$(LUA_INCLUDE_DIR) -L$(LUA_BIN_DIR)

mingw : 
	gcc -g -Wall --shared -o snapshot.dll snapshot.c -I/usr/local/include -L/usr/local/bin -llua53

mingw51 :
	gcc -g -Wall --shared -o snapshot.dll snapshot.c -I/usr/local/include -L/usr/local/bin -llua51

macosx :
	gcc -g -Wall --shared -undefined dynamic_lookup -o snapshot.so snapshot.c
