CXX ?= g++
CXXFLAGS ?= -O2 -std=c++17 -Wall -Wextra -Wpedantic

.PHONY: all clean

all: adsb_json_client

adsb_json_client: adsb_json_client.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

clean:
	$(RM) adsb_json_client
