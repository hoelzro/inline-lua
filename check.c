#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#if LUA_VERSION_NUM != 501
# error "Lua 5.1 required"
#endif

int main (void) {
    void *p = (void *) lua_getfenv;
    return 0;
}
