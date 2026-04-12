#!/bin/bash
set -e

# Extract the package locally and update pnpm-lock.yaml to match package.json
VERSION="9.3.10"
mkdir -p /tmp/peerbanhelper-src
cd /tmp/peerbanhelper-src
wget -qO- "https://github.com/PBH-BTN/PeerBanHelper/archive/refs/tags/v$VERSION.tar.gz" | tar -xz
cd PeerBanHelper-$VERSION/webui

# Initialize local pnpm and perform a real install to fix lockfile
export PNPM_HOME=$(pwd)/.pnpm-local
export PATH=$PNPM_HOME:$PATH
corepack enable
corepack prepare pnpm@9 --activate
pnpm install --no-frozen-lockfile

# Now compute the real pnpm hash from the corrected directory
cd ../..
HASH=$(nix hash path PeerBanHelper-$VERSION/webui)
echo "Fixed lockfile and computed new hash: $HASH"

# For Nix fetchPnpmDeps, the ideal way is to patch it during the build or prefetch with fixed lockfile.
