#include <iostream>
#include <omp.h>
#include <thread>
#include <vector>
#include "speck32.hpp"
#include "random.hpp"
#include "utils.hpp"


bool is_test_vector_correct() {
    const uint16_t k0 = 0x1918, k1 = 0x1110, k2 = 0x0908, k3 = 0x0100;
    const uint16_t pl = 0x6574, pr = 0x694c;
    uint16_t cl = 0, cr = 0;

    uint32_t pt = (uint32_t{pl} << 16) | uint32_t{pr};
    uint32_t ct = 0;
    std::vector<uint16_t> round_keys = gen_round_keys(k0, k1, k2, k3);;

    speck32_64(cl, cr, pl, pr, k0, k1, k2, k3);
    speck32_64(ct, pt, round_keys);

    return (cl == 0xa868) && (cr == 0x42f2) && (ct == 0xa86842f2);
}

inline bool dot_product(const uint32_t x, const uint32_t y) {
    return (__builtin_popcount(x & y)) % 2;
}

inline long double correlation(const long double probability) {
    return 2*probability - 1;
}

inline uint32_t get_state_from_indices(const std::vector<size_t> & indices) {
    uint32_t state = 0;
    for(const auto index : indices)
        state |= (uint32_t{1} << index);
    return state;
}

void verify_diff_linear_distinguisher(const std::vector<size_t> &in_diff_indices,
                                      const std::vector<size_t> &out_approx_indices,
                                      uint16_t nrounds,
                                      unsigned long long int nrandom_keys = (1UL << 18),
                                      unsigned int nthreads = std::thread::hardware_concurrency() >> 1) {

    uint32_t in_diff = get_state_from_indices(in_diff_indices);
    uint32_t out_approx = get_state_from_indices(out_approx_indices);
    long double total_ncorrect_inputs = 0.0;
    long double total_probability = 0.0;
    long double total_correlation = 0.0;

    printf("ninputs,probability,correlation,key\n"); //csv header
    #pragma omp parallel num_threads(nthreads) reduction(+:total_ncorrect_inputs, total_correlation, total_probability)\
        default(none) firstprivate(in_diff, out_approx, nrandom_keys, nthreads, nrounds)
    {
        fast_random_generator gen(get_seed());

        for(unsigned long long _ = 0; _ < (nrandom_keys / nthreads); ++_) {
            uint64_t key = gen.random_uint64();
            std::vector<uint16_t> round_keys = gen_round_keys(key, nrounds);

            uint64_t ncorrect_inputs = 0;
            uint32_t x = 0;
            do {
                uint32_t xp = x ^ in_diff;
                uint32_t y = 0, yp = 0;

                speck32_64(y, x, round_keys);
                speck32_64(yp, xp, round_keys);

                uint32_t out_diff = y ^ yp;

                if (dot_product(out_approx, out_diff) == 0)
                    ++ncorrect_inputs;

            } while(++x);

            long double prob = (long double) ncorrect_inputs / (uint64_t{1} << 32);
            long double corr = correlation(prob);

            printf("%llu,%.15Lf,%.15Lf,0x%016llX\n", ncorrect_inputs, prob, corr, key);

            total_ncorrect_inputs += ncorrect_inputs;
            total_probability += prob;
            total_correlation += corr;
        }
    };

    printf("\n");
    printf("nrounds = %u\n", nrounds);

    long double avg_ncorrect_inputs = total_ncorrect_inputs / nrandom_keys;
    printf("average no. of inputs = %.15Lf\n", avg_ncorrect_inputs);

    long double avg_probability = total_probability / nrandom_keys;
    printf("average probability  = %.15Lf\n", avg_probability);

    long double avg_correlation = total_correlation / nrandom_keys;
    printf("average correlation  = %.15Lf\n", avg_correlation);

    printf("input diff indices =");
    for(const auto index : in_diff_indices)
        printf(" %lu", index);
    printf("\n");

    printf("output approx indices = ");
    for(const auto index: out_approx_indices)
        printf(" %lu", index);
    printf("\n");
}

int main() {
    if (not is_test_vector_correct())
        throw std::runtime_error("test vector failed");

    std::string line;

    uint16_t nrounds = 0;
    std::vector<size_t> in_diff_indices;
    std::vector<size_t> out_approx_indices;

    std::getline(std::cin, line);
    nrounds = std::stoul(line);

    line.clear();
    std::getline(std::cin, line);
    in_diff_indices = to_uint_vector(split(line, ' '));

    line.clear();
    std::getline(std::cin, line);
    out_approx_indices = to_uint_vector(split(line, ' '));

    verify_diff_linear_distinguisher(in_diff_indices, out_approx_indices, nrounds);

    return 0;
}
