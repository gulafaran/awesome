CC=clang
LUA_LIB=/usr/share/awesome/lib
THEME_PATH=/usr/share/awesome/themes
XDG_CONF=/etc/xdg
VERSION=v1.0
ARCH=x86-64
RELEASE=waffles
EXTRA_CFLAGS=-march=$(ARCH) -mtune=native -O3 -fstack-protector-strong

PKGFLAGS=glib-2.0 gio-2.0 libstartup-notification-1.0 dbus-1 cairo cairo-xcb gdk-pixbuf-2.0 xcb-util libxdg-basedir xcb-xinerama xcb-randr xcb-cursor xcb-xtest xcb-shape xcb-keysyms xcb-icccm xcb-render x11-xcb lua
CFLAGS=$(EXTRA_CFLAGS) `pkg-config --cflags $(PKGFLAGS)` $(INCLUDE)
LINKER=`pkg-config --libs $(PKGFLAGS)`
INCLUDE=-Isrc/


SRC = $(wildcard src/*.c) $(wildcard src/common/*.c) $(wildcard src/objects/*.c)
OBJ = $(SRC:.c=.o)
DEPS = $(wildcard src/*.h) $(wildcard src/common/*.h) $(wildcard src/objects/*.h)

awesome: vars $(OBJ)
	mkdir -p bin/
	$(CC) $(OBJ) $(LINKER) -o bin/awesome

%.o: %.c $(DEPS)
	$(CC) -c $(CFLAGS) $< -o $@

install: awesome
	install -D -m755 bin/awesome $(DESTDIR)/usr/bin/awesome
	install -d -m755 $(DESTDIR)$(LUA_LIB)
	cp -r src/lib/* $(DESTDIR)$(LUA_LIB)
	install -d -m755 $(DESTDIR)/usr/share/awesome/themes
	cp -r themes/* $(DESTDIR)/usr/share/awesome/themes
	install -D -m644 rc.lua $(DESTDIR)$(XDG_CONF)/awesome/rc.lua

.PHONY: vars
vars:
	sed -i -r "s~AWESOMELUAPATH~$(LUA_LIB)~g" src/config.h
	sed -i -r "s~AWESOMEXDGPATH~$(XDG_CONF)~g" src/config.h
	sed -i -r "s~AWESOMEVERSION~$(VERSION)~g" src/awesome-version-internal.h
	sed -i -r "s~AWESOMEARCH~$(ARCH)~g" src/awesome-version-internal.h
	sed -i -r "s~AWESOMEREL~$(RELEASE)~g" src/awesome-version-internal.h
.PHONY: uninstall
uninstall:
	rm $(DESTDIR)/usr/bin/awesome
	rm -r $(DESTDIR)/usr/share/awesome/
	rm -r $(DESTDIR)/etc/xdg/awesome/

.PHONY: clean
clean:
	rm src/*.o src/common/*.o src/objects/*.o bin/awesome
	cp src/config.h.mk src/config.h
	cp src/awesome-version-internal.h.mk src/awesome-version-internal.h
