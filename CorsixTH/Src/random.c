/*
   A C-program for MT19937, with initialization improved 2002/1/26.
   Coded by Takuji Nishimura and Makoto Matsumoto.
   Lua interface by Peter Cawley.

   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.
   Copyright (C) 2005, Mutsuo Saito,
   All rights reserved.
   Copyright (C) 2009, Peter Cawley,
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

     1. Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote
        products derived from this software without specific prior written
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.

   Any feedback is very welcome.
   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
   email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
*/

#include <lua.h>
#include <lauxlib.h>
#ifdef _MSC_VER
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
#else
#include <stdint.h>
#endif /* _MSC_VER */

/* Period parameters */
#define N 624
#define M 397
#define MATRIX_A 0x9908b0dfUL   /* constant vector a */
#define UPPER_MASK 0x80000000UL /* most significant w-r bits */
#define LOWER_MASK 0x7fffffffUL /* least significant r bits */

uint32_t mt[N]; /* the array for the state vector  */
uint16_t mti=N+1; /* mti==N+1 means mt[N] is not initialized */

/* initializes mt[N] with a seed */
static void init_genrand(uint32_t s)
{
    mt[0]= s;
    for (mti=1; mti<N; mti++) {
        mt[mti] =
        (1812433253UL * (mt[mti-1] ^ (mt[mti-1] >> 30)) + mti);
        /* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
        /* In the previous versions, MSBs of the seed affect   */
        /* only MSBs of the array mt[].                        */
    }
}

/* generates a random number on [0,0xffffffff]-interval */
static uint32_t genrand_int32(void)
{
    uint32_t y;
    static uint32_t mag01[2]={0x0UL, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N) { /* generate N words at one time */
        int kk;

        if (mti == N+1)   /* if init_genrand() has not been called, */
            init_genrand(5489UL); /* a default initial seed is used */

        for (kk=0;kk<N-M;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        for (;kk<N-1;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1UL];

        mti = 0;
    }

    y = mt[mti++];

    /* Tempering */
    y ^= (y >> 11);
    y ^= (y << 7) & 0x9d2c5680UL;
    y ^= (y << 15) & 0xefc60000UL;
    y ^= (y >> 18);

    return y;
}

/* generates a random number on [0,1) with 53-bit resolution*/
static double genrand_res53(void)
{
    uint32_t a=genrand_int32()>>5, b=genrand_int32()>>6;
    return(a*67108864.0+b)*(1.0/9007199254740992.0);
}
/* These real versions are due to Isaku Wada, 2002/01/09 added */

/**
  @function math.random
  @arguments [[range_start, ] range_end]
  @return number

  If called with no arguments, returns a random number in the range [0, 1).
  If called with one argument, returns a random integer in the range
  [1, range_end]. If called with two or more arguments, returns a random
  integer in the range [range_start, range_end].
*/
static int l_random(lua_State *L)
{
    lua_Integer min;
    uint32_t max;
    switch(lua_gettop(L))
    {
    default:
    case 2:
        min = luaL_checkinteger(L, 1);
        max = (uint32_t)(luaL_checkinteger(L, 2) - min + 1);
        luaL_argcheck(L, max > 0, 2, "interval is empty");
        lua_pushinteger(L, min + (lua_Integer)(genrand_int32() % max));
        break;
    case 1:
        max = (uint32_t)luaL_checkinteger(L, 1);
        luaL_argcheck(L, 1 <= max, 1, "interval is empty");
        lua_pushinteger(L, (lua_Integer)(genrand_int32() % max));
        break;
    case 0:
        lua_pushnumber(L, (lua_Number)genrand_res53());
        break;
    }
    return 1;
}

/**
  @function math.randomdump
  @arguments
  @return string

  Returns a string which can later be passed to math.randomseed() to restore
  the random number generator to its current state.
*/
static int l_randomdump(lua_State *L)
{
    lua_pushlstring(L, (const char*)mt, N * 4);
    lua_pushlstring(L, (const char*)&mti, 2);
    lua_concat(L, 2);
    return 1;
}

/**
  @function math.randomseed
  @arguments number
  @arguments string
  @return

  Seeds the random number generator using the given seed number, or restores
  the random number generator state from a string previously generated from
  math.randomdump().
*/
static int l_randomseed(lua_State *L)
{
    if(lua_type(L, 1) == LUA_TSTRING)
    {
        int i;
        size_t len;
        const char *data = lua_tolstring(L, 1, &len);
        if(len != N * 4 + 2)
            luaL_argerror(L, 1, "Seed string wrong length");
        for(i = 0; i < N; ++i)
            mt[i] = ((uint32_t*)data)[i];
        mti = *(uint16_t*)(data + len - 2);
    }
    else
    {
        init_genrand((uint32_t)luaL_checkinteger(L, 1));
    }
    return 0;
}

int luaopen_random(lua_State *L)
{
    lua_getglobal(L, "math");
    lua_pushliteral(L, "random");
    lua_pushcfunction(L, l_random);
    lua_settable(L, -3);
    lua_pushliteral(L, "randomseed");
    lua_pushcfunction(L, l_randomseed);
    lua_settable(L, -3);
    lua_pushliteral(L, "randomdump");
    lua_pushcfunction(L, l_randomdump);
    lua_settable(L, -3);
    return 0;
}
