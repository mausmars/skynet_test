#include <lua.h>
#include <lauxlib.h>

#include<stdio.h>
#include<string.h>
#include <zookeeper/zookeeper.h>
#include <zookeeper/zookeeper_log.h>
#include <net/if.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>
#include <errno.h>

static const char *state2String(int state) {
    if (state == 0) return "CLOSED_STATE";
    if (state == ZOO_CONNECTING_STATE) return "CONNECTING_STATE";
    if (state == ZOO_ASSOCIATING_STATE) return "ASSOCIATING_STATE";
    if (state == ZOO_CONNECTED_STATE) return "CONNECTED_STATE";
    if (state == ZOO_EXPIRED_SESSION_STATE) return "EXPIRED_SESSION_STATE";
    if (state == ZOO_AUTH_FAILED_STATE) return "AUTH_FAILED_STATE";
    return "INVALID_STATE";
}

static const char *type2String(int state) {
    if (state == ZOO_CREATED_EVENT) return "CREATED_EVENT";
    if (state == ZOO_DELETED_EVENT) return "DELETED_EVENT";
    if (state == ZOO_CHANGED_EVENT) return "CHANGED_EVENT";
    if (state == ZOO_CHILD_EVENT) return "CHILD_EVENT";
    if (state == ZOO_SESSION_EVENT) return "SESSION_EVENT";
    if (state == ZOO_NOTWATCHING_EVENT) return "NOTWATCHING_EVENT";
    return "UNKNOWN_EVENT_TYPE";
}

void create(zhandle_t *zkhandle, char *str) {
    char path_buffer[64] = "abc";
    int bufferlen = sizeof(path_buffer);
    printf("create node in synchronous mode \n");
    int flag = zoo_create(zkhandle, str, "syn-node", 9, &ZOO_OPEN_ACL_UNSAFE, 0, path_buffer, bufferlen);
    if (flag != ZOK) {
        printf("create syn-node failed\n");
        exit(EXIT_FAILURE);
    } else { printf("created node is %s\n", path_buffer); }
}

void exists(zhandle_t *zkhandle, char *path) {
    int flag = zoo_exists(zkhandle, path, 1, NULL);
    if (flag) {
        printf("%s node already exist\n", path);
    } else {
        printf("%s node not exist\n", path);
    }
}

void getACL(zhandle_t *zkhandle, char *str) {
    struct ACL_vector acl;
    struct Stat stat;
    int flag = zoo_get_acl(zkhandle, str, &acl, &stat);
    if (flag == ZOK && acl.count > 0) {
        printf("-----------------the ACL of %s: ------------ \n", str);
        printf("%d\n", acl.count);
        printf("%d\n", acl.data->perms);
        printf("%s\n", acl.data->id.scheme);
        printf("%s\n", acl.data->id.id);
    }
}

void delete(zhandle_t *zkhandle, char *str) {
    int flag = zoo_delete(zkhandle, str, -1);
    if (flag == ZOK) { printf("delete node %s success\n", str); }
}

static int call_lua_watch(int type, int state, const char *path);

void zookeeper_watcher_g(zhandle_t *zh, int type, int state, const char *path, void *watcherCtx) {
    printf(">>> zookeeper_watcher_g \n");
    printf("type: %s\n", type2String(type));
    printf("state: %s\n", state2String(state));
    printf("path: %s\n", path);
    printf("watcherCtx: %s\n", (char *) watcherCtx);

    const clientid_t *zk_clientid;
    int rc;
    if (type == ZOO_CREATED_EVENT) {
        printf("[%s %d] znode %s created.\n", __FUNCTION__, __LINE__, path);
    } else if (type == ZOO_DELETED_EVENT) {
        printf("[%s %d] znode %s deleted.\n", __FUNCTION__, __LINE__, path);
    } else if (type == ZOO_CHANGED_EVENT) {
        printf("[%s %d] znode %s changed.\n", __FUNCTION__, __LINE__, path);
    } else if (type == ZOO_CHILD_EVENT) {
        printf("[%s %d] znode %s children changed.\n", __FUNCTION__, __LINE__, path);
    } else if (type == ZOO_SESSION_EVENT) {
        if (state == ZOO_EXPIRED_SESSION_STATE) {
            printf("[%s %d] zookeeper session expired\n", __FUNCTION__, __LINE__);
        } else if (state == ZOO_AUTH_FAILED_STATE) {
            printf("[%s %d] zookeeper session auth failed\n", __FUNCTION__, __LINE__);
        } else if (state == ZOO_CONNECTING_STATE) {
            printf("[%s %d] zookeeper session is connecting\n", __FUNCTION__, __LINE__);
        } else if (state == ZOO_ASSOCIATING_STATE) {
            printf("[%s %d] zookeeper session is associating state\n", __FUNCTION__, __LINE__);
        } else if (state == ZOO_CONNECTED_STATE) {
            zk_clientid = zoo_client_id(zh);
            printf("[%s %d] connected to zookeeper server with clientid=%lu\n", __FUNCTION__, __LINE__,
                   zk_clientid->client_id);
        } else if (state == ZOO_NOTWATCHING_EVENT) {
            printf("[%s %d] zookeeper session remove watch\n", __FUNCTION__, __LINE__);
        } else {
            printf("unknown session event state = %s, path = %s, ctxt=%s\n", state2String(state), path,
                   (char *) watcherCtx);
        }
    }
    call_lua_watch(type, state, path);
}

static lua_State *ud = NULL;
static int lua_watch = LUA_REFNIL;

static int call_lua_watch(int type, int state, const char *path) {
    printf(">>> call_lua_watch: type=%d state=%d path=%s \n", type, state, path);
    lua_State *L = ud;
    lua_settop(L,0);            //清空栈
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_watch);

    lua_pushinteger(L, type);
    lua_pushinteger(L, state);
    lua_pushstring(L, path);
    printf("top1 %d \n",lua_gettop(L));      //栈值个数
    lua_call(L, 3, 0);  //调用函数
    printf(">>> call_lua_watch: over \n");
}

static int lzookeeper_init(lua_State *L) {
    // 获取参数
    size_t host_sz = 0;
    const char *host = luaL_checklstring(L, 1, &host_sz);
    printf(">>> host %s \n", host);

	luaL_checktype(L,2,LUA_TFUNCTION);
    lua_pushvalue(L, 2);
    lua_watch = luaL_ref(L, LUA_REGISTRYINDEX);
    printf(">>> lua_watch %d \n", lua_watch);

    int recv_timeout = luaL_checkinteger(L, 3);
    printf(">>> recv_timeout %d \n", recv_timeout);

    const clientid_t *clientid = lua_touserdata(L, 4);
    printf(">>> clientid %p \n", clientid);

    void *context = lua_touserdata(L, 5);
    printf(">>> context %p \n", context);

    int flags = luaL_checkinteger(L, 6);
    printf(">>> flags %d \n", flags);

    // 获取lua状态
    // L可能会失效，保存主线程lua_State
	lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
    lua_State *gL = lua_tothread(L,-1);
    printf(">>> lua_State *gL = %p \n", gL);
    ud = gL;

    // 初始化zk
    zhandle_t *zkhandle = zookeeper_init(host, zookeeper_watcher_g, recv_timeout, clientid, context, flags);
    if (zkhandle == NULL) {
        fprintf(stderr, "Error when connecting to zookeeper servers... \n");
        exit(EXIT_FAILURE);
    }
//    create(zkhandle, "/abc");
//    exists(zkhandle, "/abc");
//    getACL(zkhandle, "/abc");
//    delete(zkhandle, "/abc");

    //轻量级用户数据，返回c指针
    lua_pushlightuserdata(L, zkhandle);
    return 1;
}

void acreate_string_completion(int rc, const  char *name, const  void *data) {
    fprintf(stderr, " [%s]: rc = %d \n ", (char*)(data==0?" null " :data), rc);
     if (!rc) {
        fprintf(stderr, " name = %s \n " , name);
    }
}

static int lacreate(lua_State *L) {
    zhandle_t *zkhandle = lua_touserdata(L, 1);
    printf(">>> zkhandle %p \n", zkhandle);

    size_t path_sz = 0;
    const char *path = luaL_checklstring(L, 2, &path_sz);
    printf(">>> path %s \n", path);

    size_t value_sz = 0;
    const char *value = luaL_checklstring(L, 3, &value_sz);
    printf(">>> value %s \n", value);

    int mode = luaL_checkinteger(L, 4);
    printf(">>> mode %d \n", mode);

    int ret = zoo_acreate(zkhandle, path, value, value_sz, &ZOO_OPEN_ACL_UNSAFE, mode, acreate_string_completion, "acreate");
    if (ret!=ZOK) {
        fprintf(stderr, " Error %d for %s\n ", ret, "acreate" );
        exit(EXIT_FAILURE);
    }else{
        printf("created node is %s\n", path);
    }
}

int luaopen_zk_async_client(lua_State *L) {
    luaL_Reg l[] = {
            {"zookeeper_init", lzookeeper_init},
            {"acreate", lacreate},
            {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}