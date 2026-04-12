#!/bin/bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
NIXPKGS_ALLOW_UNFREE=1 nix run github:nix-community/nix-build-uncached -- ci.nix -A pkgs.peerbanhelper
