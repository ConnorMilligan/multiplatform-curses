UNAME_S = $(shell uname -s)

CC = gcc
CFLAGS = -Wall
LDFLAGS = -lncurses
SDL = N
TARGET = console
MAKE = make

ifeq ($(UNAME_S), windows32)
	LDFLAGS = lib/PDCurses/wincon/pdcurses.a
	TARGET = wincon
	MAKE = mingw32-make
endif

ifeq ($(SDL), Y)
	LDFLAGS = lib/PDCurses/sdl2/pdcurses.a $(wildcard lib/SDLlib/libSDL*.a)
	TARGET = sdl
endif

SRC = $(wildcard src/*.c)
OBJ  = $(SRC:.c=.o)
BIN = bin

.PHONY: all clean

all: $(TARGET)


%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)


console: $(OBJ)
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS)

wincon: $(OBJ)
	git submodule update
	cd lib/PDCurses/wincon && $(MAKE)
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS)

sdl: $(OBJ)
	git submodule update
	cd lib && mkdir $(subst /,\,SDLlib)
	cd lib/SDLlib && cmake ../SDL -G "MinGW Makefiles" -B . && $(MAKE)
	cd lib/PDCurses/sdl2 && $(MAKE)
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS)

clean:
	-rm -f main main.exe $(OBJ)