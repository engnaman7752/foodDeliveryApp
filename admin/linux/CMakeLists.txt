cmake_minimum_required(VERSION 3.10)
project(runner)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
set(FLUTTER_APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

list(APPEND CMAKE_MODULE_PATH "${FLUTTER_MANAGED_DIR}")
list(APPEND CMAKE_MODULE_PATH "${FLUTTER_MANAGED_DIR}/generated_plugins")

include("${FLUTTER_MANAGED_DIR}/CMakeLists.txt")

add_subdirectory("runner")
