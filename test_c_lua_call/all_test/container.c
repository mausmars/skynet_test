#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int call_lua_fun(lua_State *L){

}



int main(int argc, char *argv[]){
    //新建Lua解释器
    lua_State *L = luaL_newstate();
    //载入Lua基本库
    luaL_openlibs(L);
    //运行lua脚本
    luaL_dofile(L, "user_mgr.lua");
    printf("%d\n", call_lua_fun(L));

    /* 清除Lua */
    lua_close(L);
    return 0;
}