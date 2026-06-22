cmake_minimum_required(VERSION 3.16)

project(AutomotiveDashboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Network)
qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appAutomotiveDashboard
    main.cpp
)

qt_add_qml_module(appAutomotiveDashboard
    URI AutomotiveDashboard
    QML_FILES
        Main.qml
        SOURCES backend.h backend.cpp
        SOURCES gpio_handler.h gpio_handler.cpp
        SOURCES i2c_handler.h i2c_handler.cpp
        QML_FILES Speedometer.qml
        QML_FILES RpmGauge.qml
        QML_FILES IndicatorIcon.qml
        RESOURCES
        RESOURCES
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appAutomotiveDashboard PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appAutomotiveDashboard
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appAutomotiveDashboard
    PRIVATE
        Qt6::Quick
        Qt6::Network # Indispensable pour QLocalServer/QLocalSocket
)

include(GNUInstallDirs)
install(TARGETS appAutomotiveDashboard
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
