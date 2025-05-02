BIN ?= defaultbrowser
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

CC ?= clang
CFLAGS ?= -O2
BIN_ARM64 = $(BIN)-arm64
BIN_X86_64 = $(BIN)-x86_64
UNIVERSAL_BIN = $(BIN)

.PHONY: all install uninstall clean

all: $(BIN)

$(BIN):
	$(CC) -o $(BIN) $(CFLAGS) -framework Foundation -framework ApplicationServices -framework AppKit src/main.m

universal: $(BIN_ARM64) $(BIN_X86_64)
	lipo -create -output $(BIN) $(BIN_ARM64) $(BIN_X86_64)

$(BIN_ARM64):
	$(CC) -arch arm64 -o $(BIN_ARM64) $(CFLAGS) -framework Foundation -framework ApplicationServices -framework AppKit src/main.m

$(BIN_X86_64):
	$(CC) -arch x86_64 -o $(BIN_X86_64) $(CFLAGS) -framework Foundation -framework ApplicationServices -framework AppKit src/main.m

install: $(BIN)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(BIN) $(DESTDIR)$(BINDIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN)

clean:
	rm -f $(BIN) $(BIN_ARM64) $(BIN_X86_64)
