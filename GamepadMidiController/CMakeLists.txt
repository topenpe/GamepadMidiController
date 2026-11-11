cmake_minimum_required(VERSION 3.14)
project(GamepadMidiController)

# Ensure C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

# MinGW cross-builds have the WinMM backend available, but do not include the
# Windows SDK headers needed by libremidi's newer WinMIDI/UWP backends.
if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(LIBREMIDI_NO_WINMIDI ON CACHE BOOL "Disable libremidi WinMIDI backend for MinGW" FORCE)
    set(LIBREMIDI_NO_WINUWP ON CACHE BOOL "Disable libremidi WinRT backend for MinGW" FORCE)
    set(GAMEPAD_ENABLE_TESTS OFF CACHE BOOL "Do not build libgamepad tests for the cross target" FORCE)

    # Windows threads are provided by the OS/compiler runtime. FindThreads can
    # otherwise mis-detect MinGW and add a nonexistent -lpthreads dependency.
    set(CMAKE_HAVE_LIBC_PTHREAD TRUE CACHE INTERNAL "MinGW has native thread support" FORCE)
endif()

# libremidi
FetchContent_Declare(
    libremidi
    GIT_REPOSITORY https://github.com/celtera/libremidi.git
    GIT_TAG        v5.4.3
)
# libgamepad
FetchContent_Declare(
    libgamepad
    GIT_REPOSITORY https://github.com/univrsal/libgamepad
    GIT_TAG        v1.1
)

FetchContent_MakeAvailable(libremidi)
FetchContent_MakeAvailable(libgamepad)

# libgamepad includes <Windows.h>, while MinGW's case-sensitive headers use
# <windows.h>. Provide a compatibility shim for GNU cross-builds on Unix.
if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_include_directories(gamepad PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/compat/mingw")
endif()

add_executable(GamepadMidiController
    GamepadMidiController.cpp
    GamepadMidiController.h
    output/midi1_output.cpp
)

target_include_directories(GamepadMidiController PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/input)
target_include_directories(GamepadMidiController PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/output)
target_include_directories(GamepadMidiController PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/processor)

target_link_libraries(GamepadMidiController PRIVATE libremidi)
target_link_libraries(GamepadMidiController PRIVATE gamepad)

if(WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # Bundle the MinGW C/C++ runtime into the executable for easier distribution.
    target_link_options(GamepadMidiController PRIVATE -static -static-libgcc -static-libstdc++)
endif()
