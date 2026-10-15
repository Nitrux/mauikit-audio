#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2025-2026 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -euo pipefail

# -- Prepare source.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
PACKAGE_VERSION="${PACKAGE_VERSION:-0.0.1}"
TARGET_ARCH="${TARGET_ARCH:-$(dpkg --print-architecture)}"

# -- Download Source

git clone --depth 1 --branch "${MAUIKIT_AUDIO_BRANCH}" https://github.com/Nitrux/mauikit-audio-src.git "$repo_root/mauikit-audio-src"
source_dir="$repo_root/mauikit-audio-src"

# -- Configure build.

build_dir="$repo_root/build"
meson_dir="$build_dir/meson"
stage_dir="$build_dir/package"
rm -rf "$meson_dir" "$stage_dir"
mkdir -p "$build_dir"

meson_args=(--prefix=/usr --buildtype=release)
if [ "$(dpkg-architecture -qDEB_HOST_ARCH)" = "amd64" ]; then
    meson_args+=("-Dcpp_args=-march=x86-64-v3")
fi

# -- Compile Source

meson setup "$meson_dir" "$source_dir" "${meson_args[@]}"
meson compile -C "$meson_dir" -j "$(nproc)"

# -- Install source to DESTDIR.

DESTDIR="$stage_dir" meson install -C "$meson_dir"

# -- Create DEBIAN control file.

mkdir -p "$stage_dir/DEBIAN"
cat > "$stage_dir/DEBIAN/control" <<CONTROL
Package: mauikit-audio
Version: ${PACKAGE_VERSION}
Section: libs
Priority: optional
Architecture: ${TARGET_ARCH}
Maintainer: uri_herrera@nxos.org
Provides: mauikit-audio
Depends: libarchive13,libc6,libcddb2,libcdio-cdda2t64,libcdio-paranoia2t64,libcdio19t64,libgme0,libjack-jackd2-0,libkf6coreaddons6,libkf6i18n6,libmp3lame0,libmpcdec6,libogg0,libopus0,libopusfile0,libpipewire-0.3-0t64,libpulse0,libqt6core5compat6,libqt6core6t64,libqt6gui6,libqt6qml6,libqt6quick6,libqt6quickcontrols2-6,libqt6quickshapes6,libshout3,libsoxr0,libspa-0.2-modules,libtag2,libvorbis0a,libvorbisenc2,libvorbisfile3,libwildmidi2,mauikit (>= 4.0.4),qml6-module-org-kde-kirigami,qml6-module-qtquick-controls,qml6-module-qtquick-shapes
Description: mauikit-audio
 mauikit-audio
CONTROL

# -- Create .deb.

dpkg-deb --build --root-owner-group "$stage_dir" "$build_dir/mauikit-audio_${PACKAGE_VERSION}_${TARGET_ARCH}.deb"
