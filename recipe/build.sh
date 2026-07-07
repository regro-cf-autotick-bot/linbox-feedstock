#!/bin/bash

sed -i.bak "s/INSTR_SET//g" configure.ac
sed -i.bak "s/AC_COMPILER_NAME//g" configure.ac

autoreconf -if

export CCNAM=$c_compiler
export CPPFLAGS="-DDISABLE_COMMENTATOR $CPPFLAGS"
export CFLAGS="-g -fPIC $CFLAGS"
export CXXFLAGS="-g -fPIC $CXXFLAGS"

# givaro defined bool_constant but since C++17 there is also std::bool_constant which leads to ambiguity.
# linbox needs std::binary_function which was removed in C++17.
export CXXFLAGS="$CXXFLAGS -std=c++14"

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --with-default="$PREFIX" \
    --libdir="$PREFIX/lib" \
    --without-ocl \
    --without-fplll \
    --with-iml="$PREFIX" \
    --with-ntl="$PREFIX"

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" || "$CMAKE_CROSSCOMPILING_EMULATOR" != "" ]]; then
  make check -j${CPU_COUNT}
fi
make install
