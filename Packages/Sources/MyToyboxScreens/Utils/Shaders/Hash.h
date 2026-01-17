#ifndef Hash_h
#define Hash_h

namespace Hash {
    uint uhash11(uint n);

    float hash11(float p);
    float hash21(float2 p);
    float hash31(float3 p);

    uint2 uhash22(uint2 n);
    uint3 uhash33(uint3 n);

    float2 hash22(float2 p);
    float3 hash33(float3 p);
}

#endif /* Hash_h */
