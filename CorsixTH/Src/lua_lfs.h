/*
** LuaFileSystem
** File system manipulation library
**
** Copyright (C) 2003-2010 Kepler Project.
** Copyright (C) 2010-2022 The LuaFileSystem authors.
** (http://lunarmodules.github.io/luafilesystem)
*/

/* Define 'chdir' for systems that do not implement it */
#ifdef NO_CHDIR
#define chdir(p)	(-1)
#define chdir_error	"Function 'chdir' not provided by system"
#else
#define chdir_error	strerror(errno)
#endif

#ifdef _WIN32
#define chdir(p) (_chdir(p))
#define getcwd(d, s) (_getcwd(d, s))
#define rmdir(p) (_rmdir(p))
#define LFS_EXPORT __declspec (dllexport)
#ifndef fileno
#define fileno(f) (_fileno(f))
#endif
#else
#define LFS_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

  LFS_EXPORT int luaopen_lfs(lua_State * L);

#ifdef __cplusplus
}
#endif