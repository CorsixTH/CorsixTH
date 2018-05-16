/*
Copyright (c) 2009 Peter "Corsix" Cawley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "config.h"
#include "../Src/main.h"
#include "../Src/bootstrap.h"
#include <stack>
#include <SDL.h>
#ifdef CORSIX_TH_USE_SDL_MIXER
#include <SDL_mixer.h>
#endif
// Template magic for checking type equality
template <typename T1, typename T2>
struct types_equal{ enum{
    result = -1,
}; };

template <typename T1>
struct types_equal<T1, T1>{ enum{
    result = 1,
}; };

static void cleanup(lua_State* L)
{
#ifdef CORSIX_TH_USE_SDL_MIXER
    while(Mix_QuerySpec(nullptr, nullptr, nullptr))
    {
        Mix_CloseAudio();
    }
#endif
    SDL_Quit();

    lua_close(L);
}

//! Program entry point
/*!
    Prepares a Lua state for, and catches errors from, lua_main(). By
    executing in Lua mode as soon as possible, errors can be nicely caught
    sooner, hence this function does as little as possible and leaves the rest
    for lua_main().
*/
int main(int argc, char** argv)
{
    struct compile_time_lua_check
    {
        // Lua 5.1, not 5.0, is required
        int lua_5_point_1_required[LUA_VERSION_NUM >= 501 ? 1 : -1];

        // Lua numbers must be doubles so that the mantissa has at least
        // 32 bits (floats only have 24 bits)
        int number_is_double[types_equal<lua_Number, double>::result];
    };

    bool bRun = true;

    while(bRun)
    {
        lua_State *L = NULL;

        L = luaL_newstate();
        if(L == NULL)
        {
            fprintf(stderr, "Fatal error starting CorsixTH: "
                "Cannot open Lua state.\n");
            return 0;
        }
        lua_atpanic(L, lua_panic);
        luaL_openlibs(L);
        lua_settop(L, 0);
        lua_pushcfunction(L, lua_stacktrace);
        lua_pushcfunction(L, lua_main);

        // Move command line parameters onto the Lua stack
        lua_checkstack(L, argc);
        for(int i = 0; i < argc; ++i)
        {
            lua_pushstring(L, argv[i]);
        }

        if(lua_pcall(L, argc, 0, 1) != 0)
        {
            const char* err = lua_tostring(L, -1);
            if(err != NULL)
            {
                fprintf(stderr, "%s\n", err);
            }
            else
            {
                fprintf(stderr, "An error has occurred in CorsixTH:\n"
                    "Uncaught non-string Lua error\n");
            }
            lua_pushcfunction(L, bootstrap_lua_error_report);
            lua_insert(L, -2);
            if(lua_pcall(L, 1, 0, 0) != 0)
            {
                fprintf(stderr, "%s\n", lua_tostring(L, -1));
            }
        }

        lua_getfield(L, LUA_REGISTRYINDEX, "_RESTART");
        bRun = lua_toboolean(L, -1) != 0;

        cleanup(L);

        if(bRun)
        {
            printf("\n\nRestarting...\n\n\n");
        }
    }
    return 0;
}
