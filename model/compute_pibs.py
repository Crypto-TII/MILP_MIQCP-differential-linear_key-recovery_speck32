import speck
import math
import random
def numberOfSetBits(i):
     i = i - ((i >> 1) & 0x55555555);
     i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
     return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;

def product(a, b):
    return a & b

def findParity(x):
    y = x ^ (x >> 1);
    y = y ^ (y >> 2);
    y = y ^ (y >> 4);
    y = y ^ (y >> 8);
    y = y ^ (y >> 16);

    # Rightmost bit of y holds
    # the parity value if (y&1)
    # is 1 then parity is odd
    # else even
    if (y & 1):
        return 1;
    return 0;


def numberOfSetBits(i):
    i = i - ((i >> 1) & 0x55555555);
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;

def product1(a, b):
    return numberOfSetBits(a & b) % 2

def get_kth(n,k):
    return (1&(n)>>k)

def compute_number_of_pbits_and_probability(key_size, block_size, N, alpha, gamma, p_prime):
    c = 0
    r = [0 for _ in range(block_size)]
    p = [0 for _ in range(block_size)]
    key = random.getrandbits(key_size)
    cipher = speck.SpeckCipher(key, key_size, block_size, mode='ECB', number_rounds=1)
    for i in range(2**N):
        plaintext = random.getrandbits(block_size)
        z0, lst_key0 = cipher.encrypt(plaintext)
        z1, lst_key1 = cipher.encrypt(plaintext^alpha)
        if z0^z1 == gamma:
            c += 1
            for j in range(block_size):
                zx = plaintext^(1<<j)
                z0x, lst_key0x = cipher.encrypt(zx)
                z1x, lst_key1x = cipher.encrypt(zx ^ alpha)
                if z0x^z1x == gamma:
                    r[j] += 1

    k = 1
    for j in range(block_size):
        p[j] = r[j]/c
        if p[j] >=p_prime:
            print("PIB number", k, "position", j)
            k += 1
    print("Probability of the differential trail", math.log(c/(2**N),2))

if __name__ == "__main__":
    block_size = 32
    key_size = 64
    N = 19

    # First round of ""Differential-Linear Distinguisher 3".
    print("Compute PIBs and probability of the first round of ""Differential-Linear Distinguisher 3")
    alpha_1 = int('10000001010000001000000100000000', 2)
    gamma_1 = int('00000000000000100000010000000000', 2)
    compute_number_of_pbits_and_probability(key_size, block_size, N, alpha_1, gamma_1, 1)

    # First round of ""Differential-Linear Distinguisher 4". Used to mount a
    # 13-round key recovery attack on Speck32/64, p' = 1
    print("Compute PIBs and probability of the first round of ""Differential-Linear Distinguisher 4")
    alpha_1 = int('00100000010100000010000001000000', 2)
    gamma_1 = int('10000000000000000000000100000000', 2)
    compute_number_of_pbits_and_probability(key_size, block_size, N, alpha_1, gamma_1, 1)

    # First round of ""Differential-Linear Distinguisher 6". Used to mount a
    # 14-round key recovery attack on Speck32/64, p' = 0.49
    print("Compute PIBs and probability of the first round of ""Differential-Linear Distinguisher 6")
    alpha_1 = int('00101010000100000000000000000100', 2)
    gamma_1 = int('00100000010100000010000001000000', 2)
    compute_number_of_pbits_and_probability(key_size, block_size, N, alpha_1, gamma_1, 0.49)
