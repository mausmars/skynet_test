#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"

static int l_test (lua_State *L) {
    printf("hello world\n");
    return 0;
}

static int l_sum (lua_State *L) {
    //调用lua_gettop返回栈顶的值，在函数进入之时，栈顶的值就是参数的个数，此时栈的内容：1|2|3|4|5
    int n = lua_gettop(L);

    lua_Number sum = 0.0;
    int i;
    for (i = 1; i <= n; i++) {
        //lua_isnumber判断第i个参数是否是数值；如果不是就压一个常量字符串，此时栈：1|2|3|4|5|"incorrect argument"，然后调用lua_error报错，这函数会从栈顶取字符串然后报错，中断函数的执行。
        if (!lua_isnumber(L, i)) {
            lua_pushliteral(L, "incorrect argument");
            lua_error(L);
        }
        //lua_tonumber取出第i个数值，加起来
        sum += lua_tonumber(L, i);
    }
    //lua_pushnumber压入两个值，此时栈：1|2|3|4|5|15.0|3.0
    lua_pushnumber(L, sum);
    lua_pushnumber(L, sum/n);
    //return 2告诉Lua返回了两个值，那么Lua会从栈顶取出两个值，也就是最终的输出
    return 2;
}

//c 调用lua 函数 LUA_TFUNCTION
static int l_map(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);       // 检查第1个参数必须是Table
    luaL_checktype(L, 2, LUA_TFUNCTION);    // 检查第2个参数必须是Lua函数
    int len = luaL_len(L, 1);               // 取Table的长度，此时栈内容：table|fun
    lua_createtable(L, len, 0);             // 创建一个新的table压入栈顶: table|fun|table2
    for (int i = 1; i <= len; ++i) {
        lua_pushvalue(L, 2);                // 将函数拷贝到栈顶: table|fun|table2|fun
        lua_geti(L, 1, i);                  // 取旧表的第i个值：table|fun|table2|fun|vi
        lua_call(L, 1, 1);                  // 调用Lua函数，栈顶的vi作为参数传入，函数将返回1个新值在栈顶：table|fun|table2|vi2
        lua_seti(L, 3, i);                  // 将栈顶的新值设置给新表的第i个元表：table|fun|table2
    }
    return 1;       // 此时新表在栈顶，将新表返回给Lua
}

//前面说过，对Lua来说，所有函数都是闭包，它会关联0到多个upvalue。提供给Lua调用的C函数也是一个闭包，它同样可以关联多个upvalue。一个C函数如果关联upvalue，那么大概要这样返回给Lua：
//调用lua_push...等API将upvalue入栈。
//调用lua_pushcclosure生成一个闭包放在栈顶，API的原型是这样：
// fn就是C函数，n指定有多少个upvalue在栈上。
// [-n, +1, m]表示调用它时，它会把n个upvalue从栈中弹出，生成闭包后，把这个闭包压入栈中。
// void lua_pushcclosure (lua_State *L, lua_CFunction fn, int n);      // [-n, +1, m]

static int counter(lua_State *L) {
    int val = lua_tointeger(L, lua_upvalueindex(1));  // 取出第1个upvalue
    lua_pushinteger(L, ++val);                        // 加1，nv = v+1，并压入栈
    lua_copy(L, -1, lua_upvalueindex(1));             // 更新upvalue: nv
    return 1;                                         // 把nv返回
}

int l_newCounter(lua_State *L) {
    lua_pushinteger(L, 0);              // 压0入栈，作为一个upvalue： 0
    lua_pushcclosure(L, &counter, 1);   // 生成闭包压入栈顶：closure
    return 1;                           // 返回这个闭包
}

// loader函数
int luaopen_mylib(lua_State *L) {
    luaL_Reg mylib[] = {
        {"test", l_test},
        {"sum", l_sum},
        {"map", l_map},
        {"newCounter", l_newCounter},
        { NULL, NULL },
    };

    // 新建一个库(table)
    luaL_newlibtable(L, mylib);
    // 创建一个表作为upvalue
    lua_newtable(L);
    // 将mylib里面的函数加到库表中，这些函数共享上一行创建的表，作为upvalue
    luaL_setfuncs(L, mylib, 1);

    // 新建一个库(table)，把函数加入这个库中，并返回
//    luaL_newlib(L, mylib);

    return 1;
}