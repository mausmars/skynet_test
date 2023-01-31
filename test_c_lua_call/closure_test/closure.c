#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

//-----------------------------------------------
int cclosure1(lua_State *L) {
    // 注意upvalue索引1,2是闭包依赖的，不会和其他的闭包中的索引冲突
    int upval1 = lua_tonumber(L, lua_upvalueindex(1));
    int upval2 = lua_tonumber(L, lua_upvalueindex(2));
    upval1++;
    upval2++;

    // 更新upvalue1
    lua_pushnumber(L, upval1);
    lua_replace(L, lua_upvalueindex(1));
    // 更新upvalue2
    lua_pushnumber(L, upval2);
    lua_replace(L, lua_upvalueindex(2));

    lua_pushnumber(L, upval1 + upval2);
    return 1;
}

/* 闭包产生器 */
int lcreateclosure1(lua_State *L) {
    int v1 = luaL_checkinteger(L, 1);
    int v2 = luaL_checkinteger(L, 2);

    lua_pushnumber(L, v1);              /* 压入第一个upvalue */
    lua_pushnumber(L, v2);              /* 压入第二个upvalue */
    lua_pushcclosure(L, cclosure1, 2);  /* 压入闭包的同时也把upvalue置入该闭包的upvalue表 */
    return 1;                           /* 返回闭包 */
}

//-----------------------------------------------
int cclosure2(lua_State *L) {
    double upval1 = lua_tonumber(L, lua_upvalueindex(1));
    double upval2 = lua_tonumber(L, lua_upvalueindex(2));
    upval1++;
    upval2++;

    lua_pushnumber(L, upval1);
    lua_replace(L, lua_upvalueindex(1));

    lua_pushnumber(L, upval2);
    lua_replace(L, lua_upvalueindex(2));
    lua_pushnumber(L, upval1 + upval2);
    return 1;
}

int lcreateclosure2(lua_State *L) {
    int v1 = luaL_checkinteger(L, 1);
    int v2 = luaL_checkinteger(L, 2);

    lua_pushnumber(L, v1);
    lua_pushnumber(L, v2);
    lua_pushcclosure(L, cclosure2, 2);
    return 1;
}

//------------------------------------------------
int luaopen_closure(lua_State *L) {
    luaL_Reg l[] = {
        {"createclosure1", lcreateclosure1},
        {"createclosure2", lcreateclosure2},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}