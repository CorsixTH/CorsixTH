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
    audioSupport ? true,
    movieSupport ? true,
    freetypeSupport ? true,
    buildDocs ? false,
    enableUnitTests ? false,
    # buildAnimView ? false,
}:

with pkgs.lib;

let
    lua = {
        env = pkgs.lua5_3.withPackages(ps: with ps; [ lpeg luafilesystem luasocket ]);
        packageDir = "${lua.env.outPath}/lib/lua/5.3";
    };

    SDL2_mixer = pkgs.SDL2_mixer.overrideAttrs(old: rec { 
        configureFlags = old.configureFlags ++ [ 
            " --enable-music-midi-fluidsynth-shared"
            " --disable-music-midi-timidity"
        ]; 
    });

in pkgs.stdenv.mkDerivation {
    name = "corsixth";
    version = "0.64";

    src = ./.;

    nativeBuildInputs = [
        pkgs.cmake
    ];

    buildInputs = [
        lua.env
        pkgs.SDL2
    ]
        ++ optional audioSupport SDL2_mixer
        ++ optionals (audioSupport && pkgs.stdenv.isLinux) [ pkgs.soundfont-fluid pkgs.fluidsynth ]
        ++ optional freetypeSupport pkgs.freetype
        ++ optional movieSupport pkgs.ffmpeg
        ++ optional buildDocs pkgs.doxygen
        ++ optional enableUnitTests pkgs.catch2
        #++ optional buildAnimView pkgs.wxGTK
    ;

    LUA_DIR = lua.env.outPath;
    SDL_LIBRARY = "${pkgs.SDL2.outPath}/lib/libSDL2.so";
    SDL_INCLUDE_DIR = "${pkgs.SDL2.dev.outPath}/include/SDL2";
    
    FFMPEG_DIR = optional movieSupport pkgs.ffmpeg.outPath;
    FREETYPE_DIR = optional freetypeSupport pkgs.freetype.outPath;
    SDL_MIXER_DIR = optional audioSupport SDL2_mixer.outPath;
    SDL_SOUNDFONTS = "${pkgs.soundfont-fluid.outPath}/share/soundfonts/FluidR3_GM2-2.sf2";
    # wxWidgets_ROOT_DIR = pkgs.wxGTK.outPath;
    
    cmakeFlags = [ ]
        ++ optional (!audioSupport) "-DWITH_AUDIO=OFF"
        ++ optional (!freetypeSupport) "-DWITH_FREETYPE2=OFF"
        ++ optional (!movieSupport) "-DWITH_MOVIES=OFF"
        ++ optional enableUnitTests "-DENABLE_UNIT_TESTS=ON"
        # ++ optional (buildAnimView) "-DBUILD_ANIMVIEW=ON"
    ;

    preFixup = ''
        cp -a "${lua.packageDir}"/. $out/share/corsix-th/
    '';

    shellHook = ''
        mkdir -p build
        cp -a "${lua.packageDir}"/. build/
    '';

    meta = with pkgs.lib; {
        description = "Open source clone of Theme Hospital";
        longDescription = "A reimplementation of the 1997 Bullfrog business sim Theme Hospital. As well as faithfully recreating the original, CorsixTH adds support for modern operating systems (Windows, macOS, Linux and BSD), high resolutions and much more.";
        homepage = "https://github.com/CorsixTH/CorsixTH";
        license = licenses.mit;
        platforms = platforms.linux;
    };
}
