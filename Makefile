#TODO: check integrity
LIBSODIUM_VER="0.4.2"
LIBSODIUM_URL=https://github.com/jedisct1/libsodium/releases/download/$(LIBSODIUM_VER)/libsodium-$(LIBSODIUM_VER).tar.gz
LIBSODIUM_TMP=$(CURDIR)/tmp/libsodium

download/libsodium.tar.gz:
	mkdir -p $(@D)
	cd $(@D) && wget $(LIBSODIUM_URL) -O $(@F)

build/libsodium: download/libsodium.tar.gz
	mkdir -p $(@D)
	tar -zxvf $< -C $(@D)
	mv $(@D)/libsodium-* $@

tmp/libsodium/usr/lib/libsodium.so: build/libsodium
	mkdir -p $(@D)
	cd $< && ./configure --prefix=$(LIBSODIUM_TMP)/usr && make && make check && make install

libsodium1.deb: tmp/libsodium/usr/lib/libsodium.so
	mkdir -p pkgtmp/libsodium1/DEBIAN
	cp control_files/libsodium/libsodium1/DEBIAN/* pkgtmp/libsodium1/DEBIAN
	mkdir -p pkgtmp/libsodium1/usr/lib
	cp $(LIBSODIUM_TMP)/usr/lib/libsodium.so.4.2.0 pkgtmp/libsodium1/usr/lib/
	cp $(LIBSODIUM_TMP)/usr/lib/libsodium.so.4 pkgtmp/libsodium1/usr/lib/
	dpkg-deb --build pkgtmp/libsodium1 $@

libsodium-dev.deb: tmp/libsodium/usr/lib/libsodium.so
	mkdir -p pkgtmp/libsodium-dev/DEBIAN
	cp control_files/libsodium/libsodium-dev/DEBIAN/* pkgtmp/libsodium-dev/DEBIAN
	mkdir -p pkgtmp/libsodium-dev/usr/lib
	cp $(LIBSODIUM_TMP)/usr/lib/libsodium.so pkgtmp/libsodium-dev/usr/lib/
	cp $(LIBSODIUM_TMP)/usr/lib/libsodium.a pkgtmp/libsodium-dev/usr/lib/
	cp -a $(LIBSODIUM_TMP)/usr/include pkgtmp/libsodium-dev/usr/
	dpkg-deb --build pkgtmp/libsodium-dev $@

libsodium-all: libsodium1.deb libsodium-dev.deb

libsodium-clean:
	rm -f download/libsodium.tar.gz
	rm -rf build/libsodium
	rm -rf $(LIBSODIUM_TMP)
	rm -rf pkgtmp
	rm -f libsodium1.deb libsodium-dev.deb
	
