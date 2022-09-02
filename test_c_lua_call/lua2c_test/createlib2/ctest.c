#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>

typedef struct NumArray {
    int size;
    double values[1];  /* variable part */
} NumArray;

static int newarray(lua_State *L) {
    // 检查获取参数
    int n = luaL_checkinteger(L, 1);
    size_t nbytes = sizeof(NumArray) + (n - 1)*sizeof(double);

    fprintf(stdout, "NumArray sizeof %d \r\n", sizeof(NumArray));
    fprintf(stdout, "Array sizeof %d \r\n", (n - 1)*sizeof(double));

    // lua_newuserdata 分配内存
    NumArray *a = (NumArray *)lua_newuserdata(L, nbytes);
    a->size = n;
    return 1; /* new userdatum is already on the stack */
}

static int setarray(lua_State *L) {
    // 检查获取参数
    NumArray *a = (NumArray *)lua_touserdata(L, 1);
    int index = luaL_checkinteger(L, 2);
    double value = luaL_checknumber(L, 3);

    //参数检查
    luaL_argcheck(L, a != NULL, 1, "`array' expected");
    luaL_argcheck(L, 1 <= index && index <= a->size, 2, "index out of range");

    a->values[index-1] = value;
    return 0;                       /* number of results */
}

static int getarray(lua_State *L) {
    NumArray *a = (NumArray *)lua_touserdata(L, 1);
    int index = luaL_checkinteger(L, 2);

    //参数检查
    luaL_argcheck(L, a != NULL, 1, "'array' expected");
    luaL_argcheck(L, 1 <= index && index <= a->size, 2,"index out of range");

    lua_pushnumber(L, a->values[index-1]);      /* first result */
    return 1;                                   /* number of results */
}

static int getsize(lua_State *L) {
    NumArray *a = (NumArray *)lua_touserdata(L, 1);

    luaL_argcheck(L, a != NULL, 1, "`array' expected");

    lua_pushnumber(L, a->size);
    return 1;
}

int luaopen_ctest(lua_State *L) {
    luaL_Reg l[] = {
        {"new", newarray},
        {"set", setarray},
        {"get", getarray},
        {"size", getsize},
        {NULL, NULL}
     };
    luaL_newlib(L, l);
    return 1;
};
