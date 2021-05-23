{ baseName ? "corsix-th", stdenv, lib, cmake, wxGTK30 }:

with lib;

let
    version = "0.64";
in 
stdenv.mkDerivation rec {
    inherit version;

    pname = "${baseName}-animview";

    src = ../.;

    nativeBuildInputs = [
        cmake
    ];

    buildInputs = [ wxGTK30 ];
    
    cmakeFlags = [
        "-DBUILD_CORSIXTH=OFF"
        "-DBUILD_ANIMVIEW=ON"
    ];

    buildPhase = ''
        make AnimView
    '';

    postInstall = ''
        mkdir -p $out/bin

        cp $out/AnimView/AnimView $out/bin/${pname}

        rm -rf $out/AnimView
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
