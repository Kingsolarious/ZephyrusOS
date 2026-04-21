# Zephyrus Global Menu Makefile

CC = gcc
CFLAGS = -shared -fPIC -Wall `pkg-config --cflags gtk4 dbus-1`
LIBS = `pkg-config --libs gtk4 dbus-1`

DESTDIR ?= $(HOME)/.local

all: build

build: zephyrus-gtk-menu.so

zephyrus-gtk-menu.so: gtk-menu-exporter.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

install: build
	# Install GTK module
	mkdir -p $(DESTDIR)/lib/zephyrus-menu
	cp zephyrus-gtk-menu.so $(DESTDIR)/lib/zephyrus-menu/
	
	# Install service
	mkdir -p $(DESTDIR)/bin
	cp zephyrus-menu-service.py $(DESTDIR)/bin/zephyrus-menu-service
	chmod +x $(DESTDIR)/bin/zephyrus-menu-service
	
	# Install extension
	mkdir -p $(DESTDIR)/share/gnome-shell/extensions/zephyrus-global-menu@zephyrus-os
	cp extension.js metadata.json stylesheet.css $(DESTDIR)/share/gnome-shell/extensions/zephyrus-global-menu@zephyrus-os/
	
	# Install systemd user service
	mkdir -p $(DESTDIR)/share/systemd/user
	cp zephyrus-menu.service $(DESTDIR)/share/systemd/user/
	
	@echo "Installed to $(DESTDIR)"

clean:
	rm -f zephyrus-gtk-menu.so
	rm -rf __pycache__

uninstall:
	rm -f $(DESTDIR)/lib/zephyrus-menu/zephyrus-gtk-menu.so
	rm -f $(DESTDIR)/bin/zephyrus-menu-service
	rm -rf $(DESTDIR)/share/gnome-shell/extensions/zephyrus-global-menu@zephyrus-os
	rm -f $(DESTDIR)/share/systemd/user/zephyrus-menu.service

.PHONY: all build install clean uninstall
