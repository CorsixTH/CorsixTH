{ baseName ? "corsix-th", version ? "trunk", stdenv, cmake, lib, SDL2, lua5_3, makeWrapper
, SDL2_mixer ? null, soundfont-fluid ? null, fluidsynth ? null, ffmpeg ? null, freetype ? null, doxygen ? null, catch2 ? null
, audioSupport ? true, movieSupport ? true, freetypeSupport ? true, buildDocs ? false, enableUnitTests ? false
}:

assert audioSupport -> SDL2_mixer != null && soundfont-fluid != null && fluidsynth != null;
assert movieSupport -> ffmpeg != null;
assert freetypeSupport -> freetype != null;
assert buildDocs -> doxygen != null;
assert enableUnitTests -> catch2 != null;

with lib;

let
    lua = {
        env = lua5_3.withPackages(ps: with ps; [ lpeg luafilesystem ]);
        packageDir = "${lua.env.outPath}/lib/lua/5.3";
    };

    SDL2_mixer_fix = if SDL2_mixer != null then SDL2_mixer.overrideAttrs(old: rec { 
        configureFlags = old.configureFlags ++ [ 
            " --enable-music-midi-fluidsynth-shared"
            " --disable-music-midi-timidity"
        ]; 
    }) else null;
in 
stdenv.mkDerivation rec {
    inherit version;

    pname = "${baseName}";

    src = ../.;

    nativeBuildInputs = [
        cmake
        makeWrapper
    ];

    buildInputs = [
        lua.env
        SDL2
    ]
        ++ optional audioSupport SDL2_mixer_fix
        ++ optionals (audioSupport && stdenv.isLinux) [ soundfont-fluid fluidsynth ]
        ++ optional freetypeSupport freetype
        ++ optional movieSupport ffmpeg
        ++ optional buildDocs doxygen
        ++ optional enableUnitTests catch2
    ;

    LUA_DIR = lua.env.outPath;
    LUA_PACKAGES_DIR = lua.packageDir;
    SDL_LIBRARY = "${SDL2.outPath}/lib/libSDL2.so";
    SDL_INCLUDE_DIR = "${SDL2.dev.outPath}/include/SDL2";
    
    FFMPEG_DIR = optional movieSupport ffmpeg.outPath;
    FREETYPE_DIR = optional freetypeSupport freetype.outPath;
    SDL_MIXER_DIR = optional audioSupport SDL2_mixer.outPath;
    
    cmakeFlags = [ ]
        ++ optional (!audioSupport) "-DWITH_AUDIO=OFF"
        ++ optional (!freetypeSupport) "-DWITH_FREETYPE2=OFF"
        ++ optional (!movieSupport) "-DWITH_MOVIES=OFF"
        ++ optional enableUnitTests "-DENABLE_UNIT_TESTS=ON"
    ;

    preFixup = ''
        cp -a "${lua.packageDir}"/. $out/share/corsix-th/
    '';

    postInstall = ''
        mkdir -p $out/share/bin
        mv $out/bin/${baseName} $out/share/bin
        makeWrapper $out/share/bin/${baseName} $out/bin/${baseName} \
            --set SDL_SOUNDFONTS ${soundfont-fluid.outPath}/share/soundfonts/FluidR3_GM2-2.sf2
    '';

    enableParallelBuilding = true;

    meta = with lib; {
        description = "Open source clone of Theme Hospital";
        longDescription = "A reimplementation of the 1997 Bullfrog business sim Theme Hospital. As well as faithfully recreating the original, CorsixTH adds support for modern operating systems (Windows, macOS, Linux and BSD), high resolutions and much more.";
        homepage = "https://github.com/CorsixTH/CorsixTH";
        license = licenses.mit;
        platforms = platforms.linux;
    };
}
