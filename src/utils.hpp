#ifndef SPECK_32_64_DL_UTILS_HPP
#define SPECK_32_64_DL_UTILS_HPP

#include <string>
#include <vector>

std::vector<std::string> split(const std::string & str, char delimiter) {
    std::vector<std::string> ret;
    std::size_t end = 0, begin = 0;

    while((end = str.find(delimiter, begin)) != std::string::npos) {
        std::string token = str.substr(begin, end);
        begin = end + 1;
        ret.emplace_back(std::move(token));
    }
    ret.emplace_back(str.substr(begin));
    return ret;
}

std::vector<size_t> to_uint_vector(const std::vector<std::string> & vec_str) {
    std::vector<size_t> ret;

    std::transform(vec_str.begin(), vec_str.end(), std::back_inserter(ret),
                   [](const std::string & str) { return std::stoul(str); });

    return ret;
}

#endif //SPECK_32_64_DL_UTILS_HPP
