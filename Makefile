UNAME_S = $(shell uname -s)

CC = gcc
CFLAGS = -Wall
LDFLAGS = -lncurses
SDL = N
TARGET = console
SUBMODULE = 

# Check if the host system is windows
ifeq ($(UNAME_S), windows32)
	LDFLAGS = lib/PDCurses/wincon/pdcurses.a
	TARGET = 

	ifeq ("$(wildcard $(lib/PDCurses/curses.h))","")
		TARGET = submodule
	endif

	ifeq ("$(wildcard $(lib/PDCurses/wincon/pdcurses.a))","")
		TARGET = buildwincon
	endif
	TARGET += wincon
endif

# If the target will be built with SDL
ifeq ($(SDL), Y)
	LDFLAGS = lib/PDCurses/sdl2/pdcurses.a $(wildcard lib/sld2-compat/*.a)
	TARGET =

	ifneq ("$(wildcard $(lib/PDCurses/curses.h))","")
		TARGET += submodule
	endif

	ifneq ("$(wildcard $(lib/PDCurses/sdl2/pdcurses.a))","")
		TARGET += buildsdl
	endif

	TARGET += sdl
endif

ifeq ("$(wildcard $(lib/PDCurses/curses.h))","")
    
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

buildwincon: $(OBJ)
	cd lib/PDCurses/wincon && make

wincon: $(OBJ)
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS)

buildsdl: $(OBJ)
	cd lib/sdl2-compat && cmake -DCMAKE_PREFIX_PATH="../SDL" . && make
	cd lib/PDCurses/sdl2 && make

sdl: $(OBJ)
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS) lib/sdl2-compat/libSDL2-2.0.so

submodule: $(OBJ)
	git submodule init
	git submodule update

clean:
	-rm -f main main.exe $(OBJ)
