cmake_minimum_required(VERSION 3.16)
project(curses)

option(SDL "Build the program for SDL" OFF)
include_directories("${PROJECT_SOURCE_DIR}/lib/PDCurses")
message("Build with SDL=ON for SDL support")

if(SDL)
    # Checks to see if git is present
    find_package(Git REQUIRED)

    # Initialize the submodule if not already done so
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/lib/PDCurses/curses.h")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive -- ${dir}
                WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
                COMMAND_ERROR_IS_FATAL ANY)
    endif()

    # Import SDL2 library
    set(SDL2_DIR "${PROJECT_SOURCE_DIR}/lib/SDL")
    find_package(SDL2 REQUIRED)
    include_directories(${SDL2_INCLUDE_DIRS})

    # Import PDCurses library
    include(ExternalProject)
    ExternalProject_Add(PDCurses
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/PDCurses/sdl2
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/PDCurses
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ""
        BUILD_COMMAND make SFLAGS=-I../../SDL/include SLIBS=-L../../SDL/lib -lSDL2main -lSDL2
        INSTALL_COMMAND ""
        DEPENDS SDL2::SDL2
    )

    set(LIBRARIES "${CMAKE_CURRENT_SOURCE_DIR}/lib/PDCurses/sdl2/pdcurses.a" SDL2::SDL2)
else()
    if(WIN32)
        # Checks to see if git is present
        find_package(Git REQUIRED)

        # Initialize the submodule if not already done so
        if(NOT EXISTS "${PROJECT_SOURCE_DIR}/lib/PDCurses/curses.h")
            execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive -- ${dir}
                    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
                    COMMAND_ERROR_IS_FATAL ANY)
        endif()

        # Import PDCurses library
        include(ExternalProject)
        ExternalProject_Add(PDCurses
            SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/PDCurses/wincon
            PREFIX ${CMAKE_CURRENT_BINARY_DIR}/PDCurses
            BUILD_IN_SOURCE 1
            CONFIGURE_COMMAND ""
            BUILD_COMMAND make
            INSTALL_COMMAND ""
        )
        
        set(LIBRARIES "${PROJECT_SOURCE_DIR}/lib/PDCurses/wincon/pdcurses.a")
    else()
        set(LIBRARIES ncurses)
    endif(WIN32)
endif(SDL)

file(GLOB PROJECT_HEADERS src/*.h)
file(GLOB PROJECT_SOURCES src/*.c)


add_executable(${PROJECT_NAME} ${PROJECT_SOURCES} ${PROJECT_HEADERS})

target_link_libraries(${PROJECT_NAME} ${LIBRARIES})