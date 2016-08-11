Pod::Spec.new do |spec|
  spec.name = "libmicrohttpd-iOS"
  spec.summary = "GNU libmicrohttpd"
  spec.homepage = 'https://savannah.gnu.org/projects/libmicrohttpd'
  spec.authors = "The libmicrohttpd Authors"
  spec.license = "LGPL"

  spec.version = "0.9.50.1"
  spec.source = { :http => 'https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.50.tar.gz' }

  spec.platform = :ios
  spec.ios.deployment_target = '8.0'

  spec.prepare_command = <<-CMD
    build_for_ios() {
      build_for_architecture iphoneos armv7 arm-apple-darwin
      build_for_architecture iphonesimulator i386 i386-apple-darwin
      build_for_architecture iphoneos arm64 arm-apple-darwin
      build_for_architecture iphonesimulator x86_64 x86_64-apple-darwin
      create_universal_library
    }

    build_for_architecture() {
      PLATFORM=$1
      ARCH=$2
      HOST=$3
      SDKPATH=`xcrun -sdk $PLATFORM --show-sdk-path`
      PREFIX=$(pwd)/build/$ARCH
      ./configure \
        CC=`xcrun -sdk $PLATFORM -find cc` \
        CXX=`xcrun -sdk $PLATFORM -find c++` \
        CPP=`xcrun -sdk $PLATFORM -find cc`" -E" \
        LD=`xcrun -sdk $PLATFORM -find ld` \
        AR=`xcrun -sdk $PLATFORM -find ar` \
        NM=`xcrun -sdk $PLATFORM -find nm` \
        NMEDIT=`xcrun -sdk $PLATFORM -find nmedit` \
        LIBTOOL=`xcrun -sdk $PLATFORM -find libtool` \
        LIPO=`xcrun -sdk $PLATFORM -find lipo` \
        OTOOL=`xcrun -sdk $PLATFORM -find otool` \
        RANLIB=`xcrun -sdk $PLATFORM -find ranlib` \
        STRIP=`xcrun -sdk $PLATFORM -find strip` \
        CPPFLAGS="-arch $ARCH -isysroot $SDKPATH" \
        LDFLAGS="-arch $ARCH" \
        --host=$HOST \
        --prefix=$PREFIX \
        --quiet --enable-silent-rules
      xcrun -sdk $PLATFORM make clean --quiet
      xcrun -sdk $PLATFORM make -j 16 install
    }

    create_universal_library() {
      lipo -create -output $(pwd)/build/libmicrohttpd.dylib \
        $(pwd)/build/{armv7,arm64,i386,x86_64}/lib/libmicrohttpd.dylib
    }

    build_for_ios
  CMD

  spec.source_files = "src/include/*.h"
  spec.ios.vendored_libraries = "build/libmicrohttpd.dylib"
end
