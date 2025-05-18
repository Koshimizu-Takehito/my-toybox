#include <metal_stdlib>
using namespace metal;

namespace Hash {
    constant uint k = 0x456789abu; // 算術積に使う大きな桁数の定数
    constant uint3 kkk = uint3(0x456789abu, 0x6789ab45u, 0x89ab4567u); // 算術積で使う定数
    constant uint3 uuu = uint3(1, 2, 3); // シフト数

    uint uhash11(uint n) {
        n ^= (n << 1);
        n ^= (n >> 1);
        n *= k;
        n ^= (n << 1);
        return n * k;
    }

    float hash11(float p) {
        uint n = as_type<uint>(p);
        return float(uhash11(n)) / float(UINT_MAX);
    }

    // 引数・戻り値が 2 次元の uint 型ハッシュ関数
    uint2 uhash22(uint2 n) {
        n ^= (n.yx << uuu.xy);
        n ^= (n.yx >> uuu.xy);
        n *= kkk.xy;
        n ^= (n.yx << uuu.xy);
        return n * kkk.xy;
    }

    // 引数・戻り値が 3 次元の uint 型ハッシュ関数
    uint3 uhash33(uint3 n) {
        n ^= (n.yzx << uuu);
        n ^= (n.yzx >> uuu);
        n *= kkk;
        n ^= (n.yzx << uuu);
        return n * kkk;
    }

    // 引数・戻り値が 2 次元の float 型ハッシュ関数
    float2 hash22(float2 p) {
        uint2 n = as_type<uint2>(p);
        return float2(uhash22(n)) / float2(UINT_MAX);
    }

    // 引数・戻り値が 3 次元の float 型ハッシュ関数
    float3 hash33(float3 p) {
        uint3 n = as_type<uint3>(p);
        return float3(uhash33(n)) / float3(UINT_MAX);
    }

    // 引数が 2 次元，戻り値が 1 次元の float 型ハッシュ関数
    float hash21(float2 p) {
        uint2 n = as_type<uint2>(p);
        return float(uhash22(n).x) / float(UINT_MAX);
    }

    // 引数が 3 次元，戻り値が 1 次元の float 型ハッシュ関数
    float hash31(float3 p) {
        uint3 n = as_type<uint3>(p);
        return float(uhash33(n).x) / float(UINT_MAX);
    }

}
