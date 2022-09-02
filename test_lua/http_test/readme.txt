luarocks install http
luarocks install httpclient

luarocks install lpeg_patterns

/usr/local/lib/luarocks/rocks/lpeg_patterns
-- 依赖的so 文件
/usr/local/lib/lua/5.3/
-- 依赖的lua 文件
/usr/local/share/lua/5.3/

ls /usr/local/lib/luarocks/rocks/


git clone git@github.com:wahern/cqueues.git
cd cqueues

修改 GNUmakefile
KNOWN_APIS = 5.3

lua53cpath ?= $(libdir)/lua/5.3
lua53path ?= $(datadir)/lua/5.3

make LUA_APIS="5.3"

