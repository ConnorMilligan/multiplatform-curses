cmake_minimum_required(VERSION 3.16)
project(curses)

option(SDL "Build the program for SDL" ON)
include_directories("${PROJECT_SOURCE_DIR}/lib/PDCurses")
message("Build with SDL=OFF for console support")

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
    find_package(SDL2 QUIET)
    include_directories(${SDL2_INCLUDE_DIRS})

    # If the SDL library cannot be found, build from the submodule
    if(NOT SDL2_FOUND)
        set(BUILD_SHARED_LIBS OFF)
        message(STATUS "Could not find SDL2 package. Building from submodule instead")
        add_subdirectory("${PROJECT_SOURCE_DIR}/lib/SDL")
    endif()

    # Import SDL2_ttf library
    find_package(SDL2_ttf QUIET)
    include_directories(${SDL2_TTF_INCLUDE_DIRS})

    # If the SDL library cannot be found, build from the submodule
    if(NOT SDL2_TTF_FOUND)
        set(BUILD_SHARED_LIBS OFF)
        message(STATUS "Could not find SDL2_ttf package. Building from submodule instead")
        add_subdirectory("${PROJECT_SOURCE_DIR}/lib/SDL_ttf")
    endif()

    # Import PDCurses library
    execute_process(COMMAND "${CMAKE_MAKE_PROGRAM}" WIDE=N "SFLAGS=-I${PROJECT_SOURCE_DIR}/lib/SDL/include -I${PROJECT_SOURCE_DIR}/lib/SDL_ttf" SLIBS=-L${PROJECT_SOURCE_DIR}/lib/SDL -lSDL2main -lSDL2 -lSDL2_ttf
                WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/lib/PDCurses/sdl2"
                COMMAND_ERROR_IS_FATAL ANY)

    set(LIBRARIES "${CMAKE_CURRENT_SOURCE_DIR}/lib/PDCurses/sdl2/pdcurses.a")

    # Be sure to link with the correct SDL2 lib
    if(NOT SDL2_FOUND)
        list(APPEND LIBRARIES "${PROJECT_BINARY_DIR}/lib/SDL/libSDL2d.a")
    else()
        list(APPEND LIBRARIES -lSDL2 -lSDL2main)
    endif()

    # Be sure to link with the correct SDL2_ttf lib
    if(NOT SDL2_TTF_FOUND)
        list(APPEND LIBRARIES "${PROJECT_BINARY_DIR}/lib/SDL_ttf/libSDL2_ttfd.a")
    else()
        list(APPEND LIBRARIES -lSDL2_ttf)
    endif()
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
