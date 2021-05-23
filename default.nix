{ pkgs ? (
        let 
            hostPkgs = import <nixpkgs> {};
            pinnedPkgs = hostPkgs.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "2620ac69c01adfca54c66730eb3dbbe07e6a3024";
            sha256 = "08cibk8n7cg3az94yhhbl04hrqbxqhgz7g73fbrr9bydpf0k9in1";
            };
        in
        import pinnedPkgs {})
, audioSupport ? true, movieSupport ? true, freetypeSupport ? true, buildDocs ? false, enableUnitTests ? false, buildAnimView ? true, buildLevelEdit ? true 
}:

let
    baseName = "corsix-th";
    version = "trunk";
in
pkgs.lib.makeScope pkgs.newScope (self: with self; {
    corsixth = callPackage ./nix/corsixth.nix { inherit baseName; inherit version; inherit audioSupport; inherit movieSupport; inherit freetypeSupport; inherit buildDocs; inherit enableUnitTests; };
    animView = if buildAnimView then callPackage ./nix/animView.nix { inherit baseName; inherit version; } else null;
    levelEdit = if buildLevelEdit then callPackage ./nix/levelEdit.nix { inherit baseName; inherit version; } else null;
})
