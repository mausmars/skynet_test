https://zhuanlan.zhihu.com/p/76250674


typedef int (*lua_CFunction) (lua_State *L);
lua_State代表当前线程（对应Lua里的协程）

#define luaL_newlib(L,l)  \
  (luaL_checkversion(L), luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
一共调用3个函数：

luaL_checkversion: 检查Lua版本是否一致
luaL_newlibtable: 创建一个table并压入栈顶，这其实也是一个宏，实际上调用的是lua_createtable。
luaL_setfuncs: 将l代表的函数列表设置给刚刚压入栈的表，l就是上面代码中的luaL_Reg mylib，它是一个名字和函数指针组成的数组。名字将作为表的key，函数指针就是value（这样说不严谨，看后面解析）。

--------------------------------------
正数是从栈底开始，负数从栈顶吗。
比如a b c。
1是a，-1是c
