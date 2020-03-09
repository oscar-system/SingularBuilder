# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libsingular"
version = v"0.0.5"

# Collection of sources required to build libsingular
sources = [
    "https://github.com/Singular/Sources.git" =>
    "685700007296bcb12ecd15cd6f76760dc598af41",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
export HOSTCFLAGS=-I$prefix/include
export CFLAGS=-I$prefix/include
export LDFLAGS=-Wl,-rpath,$prefix/lib
export LD_LIBRARY_PATH=$target/lib:$LD_LIBRARY_PATH
if [ $target = "x86_64-linux-gnu" ]; then mkdir -p $prefix/x86_64-linux-gnu/lib/../lib64; cp /opt/x86_64-linux-gnu/x86_64-linux-gnu/lib64/libstdc++.la /workspace/destdir/x86_64-linux-gnu/lib/../lib64/; cp /opt/x86_64-linux-gnu/x86_64-linux-gnu/lib64/libstdc++.so /workspace/destdir/x86_64-linux-gnu/lib/../lib64/; fi
cd Sources
./autogen.sh
cd ..
mkdir Singular_build
cd Singular_build
../Sources/configure --prefix=$prefix --host=$target --libdir=$prefix/lib --with-libparse --disable-static --enable-p-procs-static --disable-p-procs-dynamic --disable-gfanlib --enable-shared --with-readline=no --with-gmp=$prefix --with-flint=$prefix --with-ntl=$prefix --without-python
if [ $target = "x86_64-apple-darwin14" ]; then wget ftp://jim.mathematik.uni-kl.de:/pub/Math/Singular/utils/singular-generated.tar.gz; wget ftp://jim.mathematik.uni-kl.de:/pub/Math/Singular/utils/singular-touch.sh; tar -xvf singular-generated.tar.gz; chmod 755 singular-touch.sh; ./singular-touch.sh; fi
make -j${nproc}
make install
exit

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(:x86_64),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libpolys", :libpolys),
    LibraryProduct(prefix, "libSingular", :libsingular),
    # LibraryProduct(prefix, "customstd", :customstd),
    # LibraryProduct(prefix, "subsets", :subsets),
    ExecutableProduct(prefix, "Singular", :Singular),
    ExecutableProduct(prefix, "libparse", :libparse),
    # LibraryProduct(prefix, "syzextra", :syzextra),
    # LibraryProduct(prefix, "interval", :interval),
    LibraryProduct(prefix, "libfactory", :libfactory),
    LibraryProduct(prefix, "libsingular_resources", :libsingular_resources),
    LibraryProduct(prefix, "libomalloc", :libomalloc)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/MPFR-v4.0.2-1/build_MPFR.v4.0.2.jl",
    "https://github.com/thofma/Flint2Builder/releases/download/d46056/build_libflint.v0.0.0-d46056d45c6429f58ec63cf3c2e59b00f8431479.jl",
    "https://github.com/thofma/NTLBuilder2/releases/download/v10.5.0-1/build_libntl.v10.5.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

