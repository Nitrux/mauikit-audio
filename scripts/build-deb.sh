#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source

git clone --depth 1 --branch "$MAUIKIT_AUDIO_BRANCH" https://invent.kde.org/camiloh/mauikit-audio.git

rm -rf mauikit-audio/{examples,LICENSE,README.md}


# -- Compile Source

mkdir -p build && cd build

HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR="/usr/lib/${HOST_MULTIARCH}" \
	../mauikit-audio/

make -j"$(nproc)"

make install


# -- Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'A free and modular front-end framework for developing user experiences.' \
	'' \
	'MauiKit Audio components.' \
	'' \
	'Maui stands for Multi-Adaptable User Interface and allows ' \
	'any Maui app to run on various platforms + devices,' \
	'like Linux Desktop and Phones, Android, or Windows.' \
	'' \
	'This package contains the MauiKit audio shared library, the MauiKit audio qml module' \
	'and the MauiKit audio development files.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=mauikit-audio \
	--pkgversion="$PACKAGE_VERSION" \
	--pkgarch="$(dpkg --print-architecture)" \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=mauikit-audio \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=mauikit-audio \
	--requires="flac,libalsaplayer0,libavcodec58,libavdevice58,libavfilter7,libavformat58,libavutil56,libc6,libcddb2,libcdio-cdda2,libcdio-paranoia2,libcdio19,libfaac0,libfdk-aac2,libflac8,libgme0,libjack0,libkf6configcore6,libkf6coreaddons6,libkf6i18n6,libkf6iconthemes6,libmad0,libmpcdec6,libmpg123-0,libogg0,libopus0,libopusfile0,libpipewire-0.3-0,libpostproc55,libpulse0,libqt6core6,libqt6gui6,libqt6multimedia6,libqt6multimediawidgets6,libqt6qml6,libqt6qmlcompiler6,libqt6quick6,libqt6quickcontrols2-6,libqt6spatialaudio6,libqt6svg6,libqt6svgwidgets6,libshout3,libsidplayfp6,libsndfile1,libsoxr0,libspa-0.2-jack,libspa-0.2-modules,libswresample3,libswscale5,libtag1v5,libvorbis0a,libwildmidi2,libxmp4,mauikit \(\>= 4.0.3\),qml6-module-org-kde-kirigami,qml6-module-qtmultimedia,qml6-module-qtquick-controls,qml6-module-qtquick-shapes,qml6-module-qtquick3d-spatialaudio,qt6-declarative,wavpack" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
