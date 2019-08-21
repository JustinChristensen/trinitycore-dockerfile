#!/usr/bin/env bash

CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
    -DBoost_USE_STATIC_LIBS=ON \
    -DBZIP2_LIBRARY_RELEASE=/usr/lib/x86_64-linux-gnu/libbz2.a \
    -DMYSQL_EXTRA_LIBRARIES=/usr/lib/x86_64-linux-gnu/libz.a \
    -DOPENSSL_CRYPTO_LIBRARIES=/usr/lib/x86_64-linux-gnu/libcrypto.a \
    -DOPENSSL_SSL_LIBRARIES=/usr/lib/x86_64-linux-gnu/libssl.a \
    -DREADLINE_LIBRARY=/usr/lib/x86_64-linux-gnu/libreadline.a \
    -DZLIB_LIBRARY_RELEASE=/usr/lib/x86_64-linux-gnu/libz.a "$@"
