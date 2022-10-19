#ifndef SPECK_32_64_DL_SPECK32_HPP
#define SPECK_32_64_DL_SPECK32_HPP

#include <algorithm>
#include <cstdint>

#define WORD_SIZE 16
#define NKEY_WORDS 4
#define DEFAULT_NROUNDS 22

#define ALPHA 7
#define BETA 2

#define ROTATE_LEFT(x, r) (((x) << (r)) | ((x) >> (WORD_SIZE - (r))))
#define ROTATE_RIGHT(x, r) ROTATE_LEFT(x, WORD_SIZE - r)

inline void round_function(uint16_t & yl, uint16_t & yr, uint16_t xl, uint16_t xr, uint16_t k) {
    xl = (ROTATE_RIGHT(xl, ALPHA) + xr) ^ k;
    xr = ROTATE_LEFT(xr, BETA) ^ xl;

    yl = xl,
    yr = xr;
}


/*** Begin Generic Functions ***/
std::vector<uint16_t> gen_round_keys(const uint16_t k0, const uint16_t k1, const uint16_t k2, const uint16_t k3, const uint16_t nrounds = DEFAULT_NROUNDS) {
    uint16_t l[NKEY_WORDS - 1] = {};
    std::vector<uint16_t> rk(nrounds);

    rk[0] = k3;
    l[0] = k2;
    l[1] = k1;
    l[2] = k0;

    for(uint16_t i = 0; i < (nrounds - 1); ++i) {
        int index = i % (NKEY_WORDS - 1);
        round_function(l[index], rk[i + 1], l[index], rk[i], i);
    }

    return rk;
}

inline void speck32_64(uint16_t & cl, uint16_t & cr, const uint16_t pl, const uint16_t pr, const std::vector<uint16_t> & round_keys, const uint16_t nrounds = DEFAULT_NROUNDS) {
    cl = pl;
    cr = pr;

    for(uint16_t i = 0; i < std::min<uint16_t>(round_keys.size(), nrounds); ++i) {
        round_function(cl, cr, cl, cr, round_keys[i]);
    }
}
/*** End Generic Functions ***/


std::vector<uint16_t> gen_round_keys(const uint64_t k, const uint16_t nrounds = DEFAULT_NROUNDS) {
    uint16_t k0 = (k & 0xFFFF000000000000ULL) >> 48;
    uint16_t k1 = (k & 0x0000FFFF00000000ULL) >> 32;
    uint16_t k2 = (k & 0x00000000FFFF0000ULL) >> 16;
    uint16_t k3 = (k & 0x000000000000FFFFULL);

    return gen_round_keys(k0, k1, k2, k3, nrounds);
}

inline void speck32_64(uint16_t & cl, uint16_t & cr, const uint16_t pl, const uint16_t pr,
                       const uint16_t k0, const uint16_t k1, const uint16_t k2, const uint16_t k3) {

    auto round_keys = gen_round_keys(k0, k1, k2, k3);
    speck32_64(cl, cr, pl, pr, round_keys);
}

inline void speck32_64(uint32_t & ct, const uint32_t pt, const std::vector<uint16_t> & round_keys) {
    uint16_t nrounds = round_keys.size();

    uint16_t pl = (pt & 0xFFFF0000) >> 16;
    uint16_t pr = (pt & 0x0000FFFF);
    uint16_t cl = 0, cr = 0;

    speck32_64(cl, cr, pl, pr, round_keys, nrounds);

    ct = 0;
    ct |= uint32_t{cl} << 16;
    ct |= uint32_t{cr};
}

#endif //SPECK_32_64_DL_SPECK32_HPP
