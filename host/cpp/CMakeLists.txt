cmake_minimum_required(VERSION 3.10)
project(e200_adsb_json_client LANGUAGES CXX)

add_executable(adsb_json_client adsb_json_client.cpp)
target_compile_features(adsb_json_client PRIVATE cxx_std_17)
target_compile_options(adsb_json_client PRIVATE -Wall -Wextra -Wpedantic)
