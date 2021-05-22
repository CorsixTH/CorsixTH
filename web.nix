{
    pkgs ? (
        let 
            hostPkgs = import <nixpkgs> {};
            pinnedPkgs = hostPkgs.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "2620ac69c01adfca54c66730eb3dbbe07e6a3024";
            sha256 = "08cibk8n7cg3az94yhhbl04hrqbxqhgz7g73fbrr9bydpf0k9in1";
            };
        in
        import pinnedPkgs {}
    ),
    audioSupport ? false,
    movieSupport ? false,
    freetypeSupport ? false,
    buildAnimView ? false,
}:

with pkgs.lib;

let
    emscriptenPorts = [
        {
            name = "sdl2";
            flag = "-s USE_SDL=2";
            pkg = pkgs.fetchzip { 
                url="https://github.com/emscripten-ports/SDL2/archive/version_22.zip"; 
                sha512="2arfqqr4d5906kal43g6vs5cpl1r6dni7hl8g66g0h10maac8cibmqh5s06lap6zln8ffa876x5c3f5d7ba3426q9rhfnx53gsp9r7k"; 
            };
        }
    ] ++ optionals audioSupport [
        {
            name = "ogg";
            flag = "";
            pkg = pkgs.fetchzip {
                url="https://github.com/emscripten-ports/ogg/archive/version_1.zip";
                sha512="2zwcf1vlh4p7dpjjqqkfj65s7k51c2hv9jbxa3bl2783ql3wnklzwy1qqnmgavvbyq8xj08vi784blgc51300ir4281j9k68kiyy9q4";
            };
        }

        {
            name = "sdl2_mixer";
            flag = "-s USE_SDL_MIXER=2";
            pkg = pkgs.fetchzip {
                url="https://github.com/emscripten-ports/SDL2_mixer/archive/release-2.0.2.zip";
                sha512="13dgixa40sahvjc4afxxr0c2nq1hs14r1dhyy5fvxlbr7n4933w13qbw58rxabwsas97wwalfyd9rj9xliji6qx46lyyrmxzp1kcx28";
            };
        }
    ];

    emLocalPorts = concatStrings (intersperse "," (map (e: "${e.name}=${e.pkg}") emscriptenPorts));

    emccBaseFlags = "-s USE_WEBGL2=1 -s FULL_ES3=1 -s ASYNCIFY"; # -s USE_PTHREADS=1
    emccFlags = emccBaseFlags + " " + (concatStrings (intersperse " " (map (e: e.flag) emscriptenPorts)));

    emscripten = pkgs.emscripten.overrideDerivation (old: rec {
        buildInputs = [ pkgs.nodejs pkgs.python3 ];

        EMCC_LOCAL_PORTS = emLocalPorts;

        installPhase = ''
            appdir=$out/share/emscripten
            mkdir -p $appdir
            cp -r . $appdir
            chmod -R +w $appdir

            mkdir -p $out/bin
            for b in em++ em-config emar embuilder.py emcc emcmake emconfigure emlink.py emmake emranlib emrun emscons; do
            makeWrapper $appdir/$b $out/bin/$b \
                --set NODE_PATH ${old.nodeModules}/node_modules \
                --set EM_EXCLUSIVE_CACHE_ACCESS 1 \
                --set PYTHON ${pkgs.python3}/bin/python
            done

            export PYTHON=${pkgs.python3}/bin/python
            export NODE_PATH=${old.nodeModules}/node_modules

            # echo "SUBDIR=\"Ogg-\" + TAG" >> $out/share/emscripten/tools/ports/ogg.py

            echo 'int main() { return 42; }' > test.c

            $out/bin/emcc ${emccFlags} test.c
            $out/bin/emcc -s RELOCATABLE -s USE_SDL=2 -s USE_WEBGL2=1 -s FULL_ES3=1 test.c
        '';
    });

    luaPackages = [
        {
            name = "lpeg";
            pkg = pkgs.buildEmscriptenPackage rec {
                name = "lpeg";
                version = "1.0.2";

                src = pkgs.fetchzip {
                    url="http://www.inf.puc-rio.br/~roberto/lpeg/${name}-${version}.tar.gz";
                    sha256="1plyzw9aj6gzkc0a9x7x1z440frsna21x0rwz8wgx0i8434291gj";
                };

                buildInputs = [ pkgs.lua5_3 ];
                
                outputs = [ "out" ];

                buildPhase = ''
                    emcc -fpic -s SIDE_MODULE=1 -s EXPORT_ALL=1 -I${pkgs.lua5_3.outPath}/include *.c -o ${name}.wasm
                '';

                installPhase = ''
                    mkdir -p $out/lib
                    
                    cp ${name}.wasm $out/lib/${name}.so
                    cp ${name}.wasm $out/lib/${name}.wasm
                '';

                autoreconfPhase = "";
                configurePhase = "";
                checkPhase = "";
            };
        }

        {
            name = "lfs";
            pkg = pkgs.buildEmscriptenPackage rec {
                name = "lfs";
                version = "1.8.0";

                src = pkgs.fetchFromGitHub {
                    owner="keplerproject";
                    repo="luafilesystem";
                    rev="7c6e1b013caec0602ca4796df3b1d7253a2dd258";
                    sha512="2m3839jwxn6rk1hvap2wr2ccj9pqm8bzv7bbxxix5dyq821flcx4cha7qri6c5wm5nwjc8wxym72fk681dkjdwxg57hsd5wbm5qic4i";
                };

                buildInputs = [ pkgs.lua5_3 ];
                
                outputs = [ "out" ];

                buildPhase = ''
                    emcc -fpic -s SIDE_MODULE=1 -s EXPORT_ALL=1 -I${pkgs.lua5_3.outPath}/include src/lfs.c -o ${name}.wasm
                '';

                installPhase = ''
                    mkdir -p $out/lib

                    cp ${name}.wasm $out/lib/${name}.so
                    cp ${name}.wasm $out/lib/${name}.wasm
                '';

                autoreconfPhase = "";
                configurePhase = "";
                checkPhase = "";
            }; 
        }
    ];

    luaExternalLibraries = (map (e: "${e.pkg.outPath}/lib/${e.name}.*") luaPackages);

    lua = (pkgs.lua5_3.override {
        stdenv = pkgs.emscriptenStdenv;
    }).overrideDerivation
    (old: rec {
        outputs = [ "out" ];

        buildInputs = [ pkgs.readline ];

        dontStrip = true;

        buildPhase = ''
            rm -rf src/lua*.c
            emcc -fpic -shared -DLUA_USE_DLOPEN src/*.c -o liblua.so
        '';

        luaExtLibs = (concatStrings (intersperse " " luaExternalLibraries));

        installPhase = ''
            mkdir -p $out/lib/lua/${old.luaversion}
            mkdir -p $out/include

            cp liblua.* $out/lib/.
            cp ${luaExtLibs} $out/lib/lua/${old.luaversion}/.
            cp src/*.h* $out/include/.
        '';

        NIX_CFLAGS_COMPILE="";
        autoreconfPhase = "";
        configurePhase = "";
        checkPhase = "";
    });

    luaPackageDir = "${lua.outPath}/lib/lua/5.3";
in pkgs.stdenv.mkDerivation rec {
    name = "corsixth";
    version = "0.64";

    src = ./.;

    outputs = [ "out" ];

    nativeBuildInputs = [
        pkgs.cmake
        emscripten
    ];

    buildInputs = [
        lua
    ];

    LUA_PACKAGE_DIR = luaPackageDir;
    EMCC_LOCAL_PORTS = emLocalPorts;
    
    cmakeFlags = [
        "-DLUA_DIR=${lua.outPath}"
        "-DLUA_LIBRARIES=${lua.outPath}/lib/liblua.so"
        "-DLUA_INCLUDE_DIR=${lua.outPath}/include"
    ]
        ++ optional (!audioSupport) "-DWITH_AUDIO=OFF"
        ++ optional (!freetypeSupport) "-DWITH_FREETYPE2=OFF"
        ++ optional (!movieSupport) "-DWITH_MOVIES=OFF"
        ++ optional buildAnimView "-DBUILD_ANIMVIEW=ON"
    ;

    cmakeFlagsStr = concatStrings (intersperse " " cmakeFlags);

    # export EMCC_DEBUG=1

    configurePhase = ''
        emcmake cmake ${cmakeFlagsStr}
    '';

    buildPhase = ''
        emmake make
    '';

    installPhase = ''
        mkdir -p $out/pkg

        cp CorsixTH/*.data CorsixTH/*.js CorsixTH/*.html CorsixTH/*.wasm $out/pkg/.
        cp ${luaPackageDir}/*.wasm $out/pkg/.
    '';

    autoreconfPhase = "";
    checkPhase = "";

    meta = with pkgs.lib; {
        description = "Open source clone of Theme Hospital";
        longDescription = "A reimplementation of the 1997 Bullfrog business sim Theme Hospital. As well as faithfully recreating the original, CorsixTH adds support for modern operating systems (Windows, macOS, Linux and BSD), high resolutions and much more.";
        homepage = "https://github.com/CorsixTH/CorsixTH";
        license = licenses.mit;
        platforms = platforms.linux;
    };
}
