#include <cstdio>
#include <cstring>
#include <chrono>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

// The embedded Lua profiler needs a clock; tests do not use engine callbacks.
long long OsGetAsyncClocksPerSecond() { return 1000000000LL; }
unsigned long long OsGetAsyncTimeClocks() {
    return std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
}
void OsValidateFunctionPointer(const void*) {}

static int RunFile(lua_State* state) {
    const char* path = luaL_checkstring(state, 1);
    if (luaL_loadfile(state, path) || lua_pcall(state, 0, 0, 0)) return lua_error(state);
    return 0;
}

static int Print(lua_State* state) {
    for (int i = 1; i <= lua_gettop(state); ++i)
        printf("%s%s", i == 1 ? "" : "\t", lua_tostring(state, i) ? lua_tostring(state, i) : "(value)");
    putchar('\n');
    return 0;
}

int main(int argc, char** argv) {
    lua_State* state = luaL_newstate();
    if (!state) return 2;
    luaL_openlibs(state);
    lua_register(state, "dofile", RunFile);
    lua_register(state, "print", Print);
    lua_newtable(state);
    for (int i = 1; i < argc; ++i) {
        lua_pushstring(state, argv[i]);
        lua_rawseti(state, -2, i - 1);
    }
    lua_setglobal(state, "arg");
    bool syntaxOnly = argc > 1 && strcmp(argv[1], "--syntax") == 0;
    int result = 0;
    for (int i = syntaxOnly ? 2 : 1; i < argc; ++i) {
        result = luaL_loadfile(state, argv[i]);
        if (!result && !syntaxOnly) result = lua_pcall(state, 0, 0, 0);
        if (result) {
            fprintf(stderr, "%s: %s\n", argv[i], lua_tostring(state, -1));
            break;
        }
        if (syntaxOnly) lua_pop(state, 1);
        else break;
    }
    lua_close(state);
    return result ? 1 : 0;
}
