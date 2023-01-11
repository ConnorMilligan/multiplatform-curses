UNAME_S = $(shell uname -s)

CC = gcc
CFLAGS = -Wall
LDFLAGS = -lncurses
SDL = N
TARGET = console

ifeq ($(UNAME_S), windows32)
	LDFLAGS = lib/PDCurses/wincon/pdcurses.a
	TARGET = wincon
endif

ifeq ($(SDL), Y)
	LDFLAGS = lib/PDCurses/sdl2/pdcurses.a $(wildcard lib/sld2-compat/*.a)
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
	cd lib/PDCurses/wincon && make
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS)

sdl: $(OBJ)
	git submodule update
	cd lib/sdl2-compat && cmake -DCMAKE_PREFIX_PATH="../SDL" . && make
	cd lib/PDCurses/sdl2 && make
	$(CC) -o main $^ $(CFLAGS) $(LDFLAGS) -lSDL2

clean:
	-rm -f main main.exe $(OBJ)
