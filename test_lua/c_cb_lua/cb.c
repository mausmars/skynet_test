#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

static int lua_callback = LUA_REFNIL;
static int lua_watch = LUA_REFNIL;
static lua_State *ud = NULL;

void doit();
void doit2();
void doit3();

static int setwatch(lua_State *L){
    printf(">>> setwatch \n");
    lua_watch = luaL_ref(L, LUA_REGISTRYINDEX);
    printf(">>> setwatch lua_watch=%d \n",lua_watch);
    ud = L;

    pthread_t tidA;
    pthread_create(&tidA, NULL, &doit, NULL);
    return 0;
}

void doit() {
    int time=1;
    for (int i=0;i<2;i++) {
        printf(">>> doit sleep %d s start \n",time);
        sleep(time);
        printf(">>> doit sleep over \n");

        //回调
        lua_State *L = ud;
        lua_rawgeti(L, LUA_REGISTRYINDEX, lua_watch);
        int a=1;
        int b=2;
        int c=3;
        lua_pushinteger(L, a);
        lua_pushinteger(L, b);
        lua_pushinteger(L, c);
        lua_call(L, 3, 1);  //调用函数
    }
}

void watch(){
    printf(">>> watch \n");
}

//------------------------------------------------
static int setwatch2(lua_State *L){
    printf(">>> setwatch2 \n");
    lua_watch = luaL_ref(L, LUA_REGISTRYINDEX);

    //L可能会失效，保存主线程lua_State
	lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
    lua_State *gL = lua_tothread(L,-1);
    printf(">>> lua_State *gL = %p \n", gL);

    ud = gL;

    pthread_t tidA;
    pthread_create(&tidA, NULL, &doit2, NULL);
    return 0;
}

void doit2() {
    int time=1;
    for (int i=0;i<2;i++) {
        printf(">>> doit2 sleep %d s start \n",time);
        sleep(time);
        printf(">>> doit2 sleep over \n");

        //回调
        lua_State *L = ud;
        lua_settop(L,0);            //清空栈
        lua_rawgeti(L, LUA_REGISTRYINDEX, lua_watch);
        int a=1;
        int b=2;
        int c=3;
        lua_pushinteger(L, a);
        lua_pushinteger(L, b);
        lua_pushinteger(L, c);
        printf("top1 %d \n",lua_gettop(L));      //栈值个数
        lua_call(L, 3, 1);  //调用函数

        printf("top2 %d \n",lua_gettop(L));      //栈值个数
        printf("栈底 result v=%d \n",lua_tointeger(L, -1));
//        printf("栈顶 result v=%d \n",lua_tointeger(L, 1));
    }
}
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
    pthread_create(&tid, NULL, &doit3, NULL);
    return 0;
}

void doit3() {
    int time=1;

    printf(">>> doit3 sleep %d s start \n",time);
    sleep(time);
    printf(">>> doit3 sleep over \n");

    //回调
    lua_State *L = ud;
    lua_settop(L,0);            //清空栈
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_watch);
    lua_call(L, 0, 0);  //调用函数
}
//------------------------------------------------
static int setnotify(lua_State *L){
    lua_callback = luaL_ref(L, LUA_REGISTRYINDEX);
    return 0;
}

static int testnotify(lua_State *L){
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_callback);

    int a=1;
    int b=2;
    int c=3;
    lua_pushinteger(L, a);
    lua_pushinteger(L, b);
    lua_pushinteger(L, c);

    lua_call(L, 3, 0);
    return 0;
}

static int testenv(lua_State *L){
    lua_getglobal(L, "defcallback");

    int a=1;
    int b=2;
    int c=3;
    lua_pushinteger(L, a);
    lua_pushinteger(L, b);
    lua_pushinteger(L, c);

    lua_call(L, 3, 0);
    return 0;
}

int luaopen_cb(lua_State *L) {
    luaL_Reg l[] = {
        {"io", lio},
        {"setwatch", setwatch},
        {"setwatch2", setwatch2},
        {"setnotify", setnotify},
        {"testnotify", testnotify},
        {"testenv", testenv},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}
