#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//结构体定义
/*
基础属性
结构体
指针函数
*/
char *speak(char *msg) {
    return msg;
}

typedef struct{
   char *city;          // 国家
   int zipcode;         // 邮编
}Address;

typedef struct{
    char *name;                 // 名字
    int age;                    // 年龄
    Address *addr;              // 地址
    char *(* speak)(char *msg); // 函数指针
}User;


static int lcreate_user(lua_State *L) {
    return 0;
}


int luaopen_ctest(lua_State *L) {
    luaL_Reg l[] = {
            {"create_user", lcreate_user},
            {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}