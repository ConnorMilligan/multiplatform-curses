#include <curses.h>

int main(void) {
    
    initscr();
    
    addstr("Hello, world!");

    getch();

    endwin();
    return 0;
}

