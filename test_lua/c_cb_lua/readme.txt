测试lua调用c，传递回调函数，并由c回调lua

https://blog.csdn.net/yhhwatl/article/details/9303675
栈顶 -1   n
    -2   3
    -3   2
栈底 -n   1
---------------------------------------------------------------------------------
https://www.bookstack.cn/read/lua-5.3/spilt.50.spilt.1.5.md

Lua提供了一个独立的被称为registry的表，C代码可以自由使用，但Lua代码不能访问他

假索引
LUA_REGISTRYINDEX、LUA_ENVIRONINDEX、 LUA_GLOBALSINDEX是一个假索引（pseudo-indices），一个假索引除了他对应的值不在栈中之外，其他都类似于栈中的索引。
Lua API 中大部分接受索引作为参数的函数，其实可以理解为一张普通表格，你可以使用任何非nil的Lua值来访问她的元素。

The Registry
Lua 提供一个独立的被称为 registry 的表， C 可以自由使用，但 Lua 代码不能访问他。索引：LUA_REGISTRYINDEX，官方解释：
Lua provides a registry, a pre-defined table that can be used by any C code to store whatever Lua value it needs to store.
This table is always located at pseudo-index LUA_REGISTRYINDEX. Any C library can store data into this table, but it should take care to choose keys different from those used by other libraries, to avoid collisions.
Typically, you should use as key a string containing your library name or a light userdata with the address of a C object in your code

注意的地方：Key值，你可以使用字符串或者C函数的指针以light userdata作为键值。

为了解决Key唯一的问题，引入 References：Reference 系统是由辅助库中的一对函数组成，这对函数用来不需要担心名称冲突的将值保存到 registry 中去。
lua_rawgeti(L, LUA_REGISTRYINDEX, r);

luaL_ref Creates and returns a reference, in the table at index t, for the object at the top of the stack (and pops the object). A reference is a unique integer key.
As long as you do not manually add integer keys into table t, luaL_ref ensures the uniqueness of the key it returns. You can retrieve an object referred by reference r by calling lua_rawgeti(L, t, r).
If the object at the top of the stack is nil, luaL_ref returns the constant LUA_REFNIL. The constant LUA_NOREF is guaranteed to be different from any reference returned by luaL_ref.
luaL_unref frees a reference and its associated object.

一些问题（待补充）
为什么lua要提供这个区间？有这些变量保存在C或者宿主语言中不是也挺好的吗？
可以理解的是：
    分散在宿主语言不同部分的Lua交互代码可以很方面的获取全局信息
    上面提到的，ref速度问题。
但是看了几个实现交互库，都是这样来处理的，其根本的原因是什么呢?
---------------------------------------------------------------------------------
int lua_rawgetp (lua_State *L, int index, const void *p);
将 value 压入堆栈t[k]，其中t是给定索引处的表，并且是表示为轻k用户数据的指针。p访问是原始的；也就是说，它不调用元__index方法。 返回推送值的类型。
int lua_rawgeti (lua_State *L, int index, lua_Integer n);
将 value 压入堆栈t[n]，其中t是给定索引处的表。访问是原始的，也就是说，它不调用元__index方法。

void lua_rawsetp (lua_State *L, int index, const void *p);
等价于t[p] = v，其中t是给定索引处的表， p被编码为轻用户数据，并且v是堆栈顶部的值。
此函数从堆栈中弹出值。赋值是原始的，也就是说，它不调用__newindex元方法。
void lua_rawseti (lua_State *L, int index, lua_Integer i);
相当于t[i] = v, wheret是给定索引处的表，v是堆栈顶部的值。
此函数从堆栈中弹出值。赋值是原始的，也就是说，它不调用元__newindex方法。

int luaL_ref (lua_State *L, int t); 返回 r
针对栈顶的对象，创建并返回一个在索引 t 指向的表中的引用（最后会弹出栈顶对象）。
此引用是一个唯一的整数键。只要你不向表 t 手工添加整数键，luaL_ref 可以保证它返回的键的唯一性。你可以通过调用 lua_rawgeti(L, t, r) 来找回由r 引用的对象。函数 luaL_unref 用来释放一个引用关联的对象
如果栈顶的对象是 nil，luaL_ref 将返回常量LUA_REFNIL。常量 LUA_NOREF 可以保证和luaL_ref 能返回的其它引用值不同。

void luaL_unref (lua_State *L, int t, int ref);
释放索引 t 处表的 ref 引用对象（参见 luaL_ref ）。此条目会从表中移除以让其引用的对象可被垃圾收集。而引用 ref 也被回收再次使用。
如果 ref 为 LUA_NOREF 或 LUA_REFNIL，luaL_unref 什么也不做。

void lua_settop (lua_State *L, int index);
接受任何索引或0，并将堆栈顶部设置为此索引。如果新的顶部比旧的大，那么新的元素用nil填充。如果index为0，则删除所有堆栈元素。
int lua_gettop (lua_State *L);
返回栈顶元素的索引。因为索引从1开始，所以这个结果等于堆栈中的元素数；特别是，0 表示空堆栈。

void lua_pushvalue (lua_State *L, int index);
将给定索引处的元素的副本推送到堆栈上。
lua_pushvalue(L, 2) 并不是往栈顶插入元素2， 而是把在栈中位置为2的元素copy之后插入于栈顶中！

void lua_pop (lua_State *L, int n);
n从堆栈中弹出元素 。
---------------------------------------------------------------------------------
https://simion.com/info/lua_capi.html
https://blog.csdn.net/fengbangyue/article/details/7342274
下面是一个在文档中列举的一个例子：
The following example shows how the host program can do the equivalent to this Lua code:
     a = f("how", t.x, 14)
Here it is in C:
     lua_getfield(L, LUA_GLOBALSINDEX, "f"); /* function to be called */
     lua_pushstring(L, "how");                        /* 1st argument */
     lua_getfield(L, LUA_GLOBALSINDEX, "t");   /* table to be indexed */
     lua_getfield(L, -1, "x");        /* push result of t.x (2nd arg) */
     lua_remove(L, -2);                  /* remove 't' from the stack */
     lua_pushinteger(L, 14);                          /* 3rd argument */
     lua_call(L, 3, 1);     /* call 'f' with 3 arguments and 1 result */
     lua_setfield(L, LUA_GLOBALSINDEX, "a");        /* set global 'a' */

在上面的例子中，可能再调用lua_getfield时就会忘记调用lua_remove,当然这是我想象自己使用时会犯下的错。lua_getfield函数功能是从指定表中取出指定元素的值并压栈。上面获取t.x的值的过程就是先调用
lua_getfield(L, LUA_GLOBALSINDEX, "t"); 从全局表中获取t的值，然而t本身是一个表，现在栈顶的值是t表。于是再一次
lua_getfield(L, -1, "x"); 从t中取出x的值放到栈上，-1表示栈顶。那该函数执行完成后t的位置由-1就变成-2了，所以下面一句
lua_remove索引的是-2，必须把t给remove掉，否则栈中就是4个参数了。上面的最后一句lua_setfield的目的是把返回值取回赋给全局变量a,因为在lua_call执行完成后，栈顶的就是返回值了。
---------------------------------------------------------------------------------
可以参考 lua-skynet.c 的 lcallback函数和_cb函数，还是有理解的地方。。。

