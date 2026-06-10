# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.2.0)
set(toolchainVersion RISCV_ZCB_RPI_2_2_0_3)
set(picotoolVersion 2.2.0-a4)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico2 CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(microsdk_project C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1

#### Uncomment the example that you want to compile

# add_executable(microsdk_project gpio_simple.c )
# add_executable(microsdk_project gpio_simple_input.c )
# add_executable(microsdk_project timer_simple.c )
# add_executable(microsdk_project gpio_LED_matrix.c )
# add_executable(microsdk_project gpio_LED_matrix_numpad.c )
# add_executable(microsdk_project gpio_interrupt.c )
# add_executable(microsdk_project alarm_interrupt.c )
# add_executable(microsdk_project lcd_simple.c )
# add_executable(microsdk_project uart.c )
# add_executable(microsdk_project usb_serial.c )
# add_executable(microsdk_project i2c_basic.c )
# add_executable(microsdk_project multicore_scheduler.c )
# add_executable(microsdk_project dma_basic.c )
# add_executable(microsdk_project pwm_simple.c )
 add_executable(microsdk_project asm.S )

pico_set_program_name(microsdk_project "microsdk_project")
pico_set_program_version(microsdk_project "0.1")


# Add the standard library to the build
target_link_libraries(microsdk_project
        pico_stdlib hal lcd traps multicore usb_cdc)

add_subdirectory( ${CMAKE_CURRENT_LIST_DIR}/sdk/hal )
add_subdirectory( ${CMAKE_CURRENT_LIST_DIR}/sdk/lcd )
add_subdirectory( ${CMAKE_CURRENT_LIST_DIR}/sdk/trap )
add_subdirectory( ${CMAKE_CURRENT_LIST_DIR}/sdk/multicore )
add_subdirectory( ${CMAKE_CURRENT_LIST_DIR}/sdk/usb_cdc )
# Add the standard include files to the build
target_include_directories(microsdk_project PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

pico_add_extra_outputs(microsdk_project)