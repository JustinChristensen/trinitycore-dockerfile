#!/usr/bin/env bash

cmake "$@" \
	-DCMAKE_C_COMPILER=/usr/bin/clang \
	-DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DWITHOUT_GIT=ON
	#-DCMAKE_EXE_LINKER_FLAGS="-static" \
    #-DBUILD_SHARED_LIBS=OFF \
    #-DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
    #-DBoost_USE_STATIC_LIBS=ON \
    #-DBZIP2_LIBRARY_RELEASE=/usr/lib/x86_64-linux-gnu/libbz2.a \
    #-DMYSQL_LIBRARY=/usr/lib/x86_64-linux-gnu/libmariadb.a \
    #-DMYSQL_EXTRA_LIBRARIES=/usr/lib/x86_64-linux-gnu/libz.a \
    #-DOPENSSL_CRYPTO_LIBRARIES=/usr/lib/x86_64-linux-gnu/libcrypto.a \
    #-DOPENSSL_SSL_LIBRARIES=/usr/lib/x86_64-linux-gnu/libssl.a \
    #-DREADLINE_LIBRARY=/usr/lib/x86_64-linux-gnu/libreadline.a \
    #-DZLIB_LIBRARY_RELEASE=/usr/lib/x86_64-linux-gnu/libz.a \
