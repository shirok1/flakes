lix eval --expr 'with import <nixpkgs> {}; pkgs.lib.isDerivation (pkgs.callPackage ./peerbanhelper.nix {})'
