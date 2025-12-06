#include <metal_stdlib>
using namespace metal;

namespace Mod {
    half mod(half x, half y) {
        return x - y * floor(x / y);
    }

    float mod(float x, float y) {
        return x - y * floor(x / y);
    }

    half2 mod(half2 x, half2 y) {
        return x - y * floor(x / y);
    }

    half3 mod(half3 x, half3 y) {
        return x - y * floor(x / y);
    }

    half4 mod(half4 x, half4 y) {
        return x - y * floor(x / y);
    }

    float2 mod(float2 x, float2 y) {
        return x - y * floor(x / y);
    }

    float3 mod(float3 x, float3 y) {
        return x - y * floor(x / y);
    }

    float4 mod(float4 x, float4 y) {
        return x - y * floor(x / y);
    }
}
