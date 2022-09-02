#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* 结构体定义 */
typedef struct{
    int x;
    int y;
    char *str;
}TData;

int call_lua_fun(lua_State *L, int a, int b){
    /* 初始化结构体 */
    TData data;
    data.x = a;
    data.y = b;
    data.str = malloc(10);
    memset(data.str, 'c', 9);
    data.str[9] = '\0';

    /* 获取Lua脚本中函数名为“fun”的函数并压入栈中 */
    lua_getglobal(L, "fun");

    /* 创建一个新的table并压入栈中 */
    lua_newtable(L);
    /* 第一个操作数入栈，int类型可以用lua_pushinteger或lua_pushnumber */
    lua_pushinteger(L, data.x);
    /*
     * 将值设置到table中，Lua脚本中可以用“.a”获取结构体x成员的值
     * 第三个参数的值可以随便取，只要和Lua脚本中保持一致即可
     */
    lua_setfield(L, -2, "a");
    /* 第二个操作数入栈 */
    lua_pushnumber(L, data.y);
    lua_setfield(L, -2, "b");
    /* 第三个操作数入栈，char*用lua_pushstring */
    lua_pushstring(L, data.str);
    lua_setfield(L, -2, "s");

    /*
     * 调用函数，调用完成后，会将返回值压入栈中
     * 第二个参数表示入参个数，第三个参数表示返回结果个数
     */
    lua_pcall(L, 1, 1, 0);
    /* 获取栈顶元素（结果） */
    int sum = (int)lua_tonumber(L, -1);
    /* 清除堆栈、清除计算结果 */
    lua_pop(L, 1);

    return sum;
}

int main(int argc, char *argv[]){
    /* 新建Lua解释器 */
    lua_State *L = luaL_newstate();
    /* 载入Lua基本库 */
    luaL_openlibs(L);
    /* 运行脚本fun.lua */
    luaL_dofile(L, "fun.lua");
    printf("%d\n", call_lua_fun(L, 5, 6));

    /* 清除Lua */
    lua_close(L);
    return 0;
}