cmake_minimum_required(VERSION 3.10)
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

    #set(SDL_LIBRARY "2.27.0")
    set(SDL_INCLUDE_DIR "${PROJECT_SOURCE_DIR}/lib/SDL/include")
    find_package(SDL2 REQUIRED)
    include_directories("SDL_INCLUDE_DIR")
    add_subdirectory("lib/SDL")

    file(COPY "${PROJECT_SOURCE_DIR}/lib/Makefile" DESTINATION "${PROJECT_SOURCE_DIR}/lib/PDCurses/sdl2")
    execute_process(COMMAND "${CMAKE_MAKE_PROGRAM}"
                WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/lib/PDCurses/sdl2"
                COMMAND_ERROR_IS_FATAL ANY)

    set(LIBRARIES "${PROJECT_SOURCE_DIR}/lib/PDCurses/sdl2/pdcurses.a" ${SDL2_LIBRARIES})
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

        execute_process(COMMAND "${CMAKE_MAKE_PROGRAM}"
                WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/lib/PDCurses/wincon"
                COMMAND_ERROR_IS_FATAL ANY)
        
        set(LIBRARIES "${PROJECT_SOURCE_DIR}/lib/PDCurses/wincon/pdcurses.a")
    else()
        set(LIBRARIES ncurses)
    endif(WIN32)
endif(SDL)

file(GLOB PROJECT_HEADERS src/*.h)
file(GLOB PROJECT_SOURCES src/*.c)
file(GLOB PROJECT_CONFIGS CMakeLists.txt
                          Readme.md
                         .gitattributes
                         .gitignore
                         .gitmodules)

add_executable(${PROJECT_NAME} ${PROJECT_SOURCES} ${PROJECT_HEADERS} ${PROJECT_CONFIGS})

target_link_libraries(${PROJECT_NAME} ${LIBRARIES})