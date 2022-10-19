#ifndef SPECK_32_64_DL_RANDOM_HPP
#define SPECK_32_64_DL_RANDOM_HPP

#include <cstdint>
#include <fcntl.h>
#include <unistd.h>

uint64_t get_seed() {
    uint64_t seed = 0;
    int urandom_fd = 0;

    urandom_fd = open("/dev/urandom", O_RDONLY);
    if (urandom_fd < 0) {
        throw std::runtime_error("unable to open /dev/urandom");
    }
    if (read(urandom_fd, &seed, sizeof(seed)) < 0) {
        throw std::runtime_error("unable to read /dev/urandom");
    }
    close(urandom_fd);

    return seed;
}

class fast_random_generator {
public:
    fast_random_generator() : _state(1) {};
    fast_random_generator(const uint64_t seed) : _state(seed) {}

    inline uint64_t random_uint64() {
        _state ^= _state >> 12;
        _state ^= _state << 25;
        _state ^= _state >> 27;
        return _state * 0x2545F4914F6CDD1DULL;
    }

private:
    uint64_t _state;
};

#endif //SPECK_32_64_DL_RANDOM_HPP
