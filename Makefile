#TODO: check integrity
DEBIAN_ARCH=$(shell dpkg --print-architecture)

LIBSODIUM_VER="0.4.2"
LIBSODIUM_URL=https://github.com/jedisct1/libsodium/releases/download/$(LIBSODIUM_VER)/libsodium-$(LIBSODIUM_VER).tar.gz
LIBSODIUM_TMP=$(CURDIR)/tmp/libsodium

LIBTOXCORE_GIT_VER="b9896e31dcef302f6f454f2256ae02a32a5714ac"
LIBTOXCORE_GIT_URL=https://github.com/irungentoo/ProjectTox-Core.git
LIBTOXCORE_TMP=$(CURDIR)/tmp/libtoxcore

TOXPRPL_GIT_VER="34824029ca454029a4852d46a508a1c6f291f422"
TOXPRPL_GIT_URL=https://github.com/jin-eld/tox-prpl.git
TOXPRPL_TMP=$(CURDIR)/tmp/toxprpl

CFLAGS="-march=native -O3"

download/libsodium.tar.gz:
	mkdir -p $(@D)
	wget $(LIBSODIUM_URL) -O $@

build/libsodium: download/libsodium.tar.gz
	mkdir -p $(@D)
	tar -zxvf $< -C $(@D)
	mv $(@D)/libsodium-* $@

tmp/libsodium/usr/lib/libsodium.so: build/libsodium
	mkdir -p $(@D)
	cd $< && CFLAGS=$(CFLAGS) ./configure --prefix=$(LIBSODIUM_TMP)/usr && make && make check && make install

libsodium1.deb: tmp/libsodium/usr/lib/libsodium.so
	mkdir -p pkgtmp/libsodium1/DEBIAN
	cp control_files/$(DEBIAN_ARCH)/libsodium/libsodium1/DEBIAN/* pkgtmp/libsodium1/DEBIAN
	mkdir -p pkgtmp/libsodium1/usr/lib
	cp -a $(LIBSODIUM_TMP)/usr/lib/libsodium.so.4.2.0 pkgtmp/libsodium1/usr/lib/
	cp -a $(LIBSODIUM_TMP)/usr/lib/libsodium.so.4 pkgtmp/libsodium1/usr/lib/
	dpkg-deb --build pkgtmp/libsodium1 $@

libsodium-dev.deb: tmp/libsodium/usr/lib/libsodium.so
	mkdir -p pkgtmp/libsodium-dev/DEBIAN
	cp control_files/$(DEBIAN_ARCH)/libsodium/libsodium-dev/DEBIAN/* pkgtmp/libsodium-dev/DEBIAN
	mkdir -p pkgtmp/libsodium-dev/usr/lib
	cp -a $(LIBSODIUM_TMP)/usr/lib/libsodium.so pkgtmp/libsodium-dev/usr/lib/
	cp -a $(LIBSODIUM_TMP)/usr/lib/libsodium.a pkgtmp/libsodium-dev/usr/lib/
	cp -a $(LIBSODIUM_TMP)/usr/include pkgtmp/libsodium-dev/usr/
	dpkg-deb --build pkgtmp/libsodium-dev $@

libsodium-all: libsodium1.deb libsodium-dev.deb

libsodium-clean:
	rm -f download/libsodium.tar.gz
	rm -rf build/libsodium
	rm -rf $(LIBSODIUM_TMP)
	rm -rf pkgtmp/libsodium1
	rm -rf pkgtmp/libsodium-dev
	rm -f libsodium1.deb libsodium-dev.deb
	
	
build/ProjectTox-Core:
	mkdir -p $(@D)
	cd $(@D) && git clone $(LIBTOXCORE_GIT_URL) && cd $(@F) && git checkout $(LIBTOXCORE_GIT_VER)

tmp/libtoxcore/usr/lib/libtoxcore.so: build/ProjectTox-Core
	mkdir -p $(@D)
	cd $< && sh autogen.sh && CFLAGS=$(CFLAGS) ./configure --disable-dht-bootstrap-daemon --prefix=$(LIBTOXCORE_TMP)/usr && make && make install

libtoxcore1.deb: tmp/libtoxcore/usr/lib/libtoxcore.so
	mkdir -p pkgtmp/libtoxcore1/DEBIAN
	cp control_files/$(DEBIAN_ARCH)/libtoxcore/libtoxcore1/DEBIAN/* pkgtmp/libtoxcore1/DEBIAN
	mkdir -p pkgtmp/libtoxcore1/usr/lib
	cp -a $(LIBTOXCORE_TMP)/usr/lib/libtoxcore.so.0.0.0 pkgtmp/libtoxcore1/usr/lib/
	cp -a $(LIBTOXCORE_TMP)/usr/lib/libtoxcore.so.0 pkgtmp/libtoxcore1/usr/lib/
	dpkg-deb --build pkgtmp/libtoxcore1 $@

libtoxcore-dev.deb: tmp/libtoxcore/usr/lib/libtoxcore.so
	mkdir -p pkgtmp/libtoxcore-dev/DEBIAN
	cp control_files/$(DEBIAN_ARCH)/libtoxcore/libtoxcore-dev/DEBIAN/* pkgtmp/libtoxcore-dev/DEBIAN
	mkdir -p pkgtmp/libtoxcore-dev/usr/lib
	cp -a $(LIBTOXCORE_TMP)/usr/lib/libtoxcore.so pkgtmp/libtoxcore-dev/usr/lib/
	cp -a $(LIBTOXCORE_TMP)/usr/lib/libtoxcore.a pkgtmp/libtoxcore-dev/usr/lib/
	cp -a $(LIBTOXCORE_TMP)/usr/lib/pkgconfig pkgtmp/libtoxcore-dev/usr/lib/
	cp -a $(LIBTOXCORE_TMP)/usr/include pkgtmp/libtoxcore-dev/usr/
	dpkg-deb --build pkgtmp/libtoxcore-dev $@

libtoxcore-all: libtoxcore1.deb libtoxcore-dev.deb

libtoxcore-clean:
	rm -rf build/ProjectTox-Core
	rm -rf $(LIBTOXCORE_TMP)
	rm -rf pkgtmp/libtoxcore1
	rm -rf pkgtmp/libtoxcore-dev
	rm -f libtoxcore1.deb libtoxcore-dev.deb


build/tox-prpl:
	mkdir -p $(@D)
	cd $(@D) && git clone $(TOXPRPL_GIT_URL) && cd $(@F) && git checkout $(TOXPRPL_GIT_VER)
	
tmp/toxprpl/usr/lib/purple-2/libtox.so: build/tox-prpl
	mkdir -p $(@D)
	cd $< && autoreconf -i && CFLAGS=$(CFLAGS) ./configure --prefix=$(TOXPRPL_TMP)/usr && make && make install

toxprpl.deb: tmp/toxprpl/usr/lib/purple-2/libtox.so
	mkdir -p pkgtmp/toxprpl/DEBIAN
	cp control_files/$(DEBIAN_ARCH)/toxprpl/DEBIAN/* pkgtmp/toxprpl/DEBIAN
	mkdir -p pkgtmp/toxprpl/usr/lib/purple-2
	mkdir -p pkgtmp/toxprpl/usr/share/
	cp -a $(TOXPRPL_TMP)/usr/share/pixmaps pkgtmp/toxprpl/usr/share/
	cp -a $(TOXPRPL_TMP)/usr/lib/purple-2/libtox.so pkgtmp/toxprpl/usr/lib/purple-2
	dpkg-deb --build pkgtmp/toxprpl $@
	
toxprpl-all: toxprpl.deb

toxprpl-clean:
	rm -rf build/tox-prpl
	rm -rf $(TOXPRPL_TMP)
	rm -rf pkgtmp/toxprpl
	rm -f toxprpl.deb
	
clean: libsodium-clean libtoxcore-clean toxprpl-clean
