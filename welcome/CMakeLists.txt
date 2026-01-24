cmake_minimum_required(VERSION 3.19)

project(caelestia-welcome VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Gui)

qt6_add_executable(caelestia-welcome
    main.cpp
)

set_target_properties(caelestia-welcome PROPERTIES
    AUTOMOC ON
)

qt6_add_qml_module(caelestia-welcome
    URI caelestia.welcome
    VERSION 1.0
    QML_FILES
        main.qml
        Colours.qml
    SOURCES
        qmldir
)

target_link_libraries(caelestia-welcome PRIVATE
    Qt6::Core
    Qt6::Gui
)

set_target_properties(caelestia-welcome PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

install(TARGETS caelestia-welcome
    RUNTIME DESTINATION bin
)
