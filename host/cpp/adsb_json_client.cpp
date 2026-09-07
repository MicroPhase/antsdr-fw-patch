// Receive decoded ADS-B JSON events from an E200 readsb instance.
// The board performs IIO acquisition and ADS-B decoding; this program only
// consumes the newline-delimited JSON result stream (default TCP port 8081).

#include <arpa/inet.h>
#include <cerrno>
#include <csignal>
#include <cstring>
#include <iostream>
#include <netinet/in.h>
#include <regex>
#include <stdexcept>
#include <string>
#include <sys/socket.h>
#include <unistd.h>

namespace {
volatile std::sig_atomic_t stop_requested = 0;

void on_signal(int) { stop_requested = 1; }

bool connect_to(const std::string &host, int port, int &fd) {
    fd = ::socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        return false;
    }

    sockaddr_in address{};
    address.sin_family = AF_INET;
    address.sin_port = htons(static_cast<uint16_t>(port));
    if (::inet_pton(AF_INET, host.c_str(), &address.sin_addr) != 1) {
        errno = EINVAL;
        ::close(fd);
        fd = -1;
        return false;
    }
    if (::connect(fd, reinterpret_cast<sockaddr *>(&address), sizeof(address)) < 0) {
        ::close(fd);
        fd = -1;
        return false;
    }
    return true;
}

std::string field(const std::string &json, const char *name) {
    const std::regex pattern(std::string("\\\"") + name +
                             "\\\"\\s*:\\s*(?:\\\"([^\\\"]*)\\\"|([^,}]+))");
    std::smatch match;
    if (!std::regex_search(json, match, pattern)) {
        return {};
    }
    return match[1].matched ? match[1].str() : match[2].str();
}

void print_event(const std::string &json) {
    std::string hex = field(json, "hex");
    if (hex.empty()) {
        hex = field(json, "icao");
    }
    std::string flight = field(json, "flight");
    if (flight.empty()) {
        flight = field(json, "callsign");
    }
    const std::string altitude = [&json] {
        std::string value = field(json, "alt_baro");
        return value.empty() ? field(json, "altitude") : value;
    }();
    const std::string lat = field(json, "lat");
    const std::string lon = field(json, "lon");

    std::cout << "ADS-B hex=" << (hex.empty() ? "?" : hex);
    if (!flight.empty()) {
        std::cout << " flight=" << flight;
    }
    if (!altitude.empty()) {
        std::cout << " alt=" << altitude;
    }
    if (!lat.empty() && !lon.empty()) {
        std::cout << " pos=" << lat << ',' << lon;
    }
    std::cout << '\n' << json << std::endl;
}
} // namespace

int main(int argc, char **argv) {
    const std::string host = argc > 1 ? argv[1] : "192.168.10.122";
    int port = 8081;
    try {
        if (argc > 2) {
            port = std::stoi(argv[2]);
        }
    } catch (const std::exception &) {
        std::cerr << "invalid TCP port: " << argv[2] << '\n';
        return 2;
    }
    if (port < 1 || port > 65535) {
        std::cerr << "TCP port must be between 1 and 65535\n";
        return 2;
    }

    std::signal(SIGINT, on_signal);
    std::signal(SIGTERM, on_signal);

    std::string pending;
    while (!stop_requested) {
        int fd = -1;
        if (!connect_to(host, port, fd)) {
            std::cerr << "connect " << host << ':' << port
                      << " failed: " << std::strerror(errno) << '\n';
            ::sleep(3);
            continue;
        }

        std::cerr << "connected to " << host << ':' << port << '\n';
        char buffer[8192];
        while (!stop_requested) {
            const ssize_t count = ::recv(fd, buffer, sizeof(buffer), 0);
            if (count <= 0) {
                break;
            }
            pending.append(buffer, static_cast<size_t>(count));
            size_t end = 0;
            while ((end = pending.find('\n')) != std::string::npos) {
                std::string line = pending.substr(0, end);
                pending.erase(0, end + 1);
                if (!line.empty() && line.front() == '{') {
                    print_event(line);
                }
            }
        }
        ::close(fd);
        if (!stop_requested) {
            std::cerr << "connection closed; reconnecting in 3 seconds\n";
            ::sleep(3);
        }
    }
    return 0;
}
