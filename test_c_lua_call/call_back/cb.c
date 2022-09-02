#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

static int lua_watch = LUA_REFNIL;
static lua_State *ud = NULL;

void doit();

//------------------------------------------------
static int lio(lua_State *L){
    printf(">>> io \n");
    lua_watch = luaL_ref(L, LUA_REGISTRYINDEX);

    //L可能会失效，保存主线程lua_State
	lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
    lua_State *gL = lua_tothread(L,-1);
    printf(">>> lua_State *gL = %p \n", gL);

    ud = gL;

    pthread_t tid;
    pthread_create(&tid, NULL, &doit, NULL);
    return 0;
}

void doit() {
    int time=1;

    printf(">>> doit sleep %d s start \n",time);
    sleep(time);
    printf(">>> doit sleep over \n");

    //回调
    lua_State *L = ud;
    lua_settop(L,0);            //清空栈
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_watch);
    lua_call(L, 0, 0);  //调用函数
}
//------------------------------------------------
int luaopen_cb(lua_State *L) {
    luaL_Reg l[] = {
        {"io", lio},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}
