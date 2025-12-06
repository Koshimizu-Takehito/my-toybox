#include <metal_stdlib>
#include "Hash.h"
#include "Metric.h"
#include "Mod.h"
using namespace metal;

namespace Metric {
    float length2(float2 x, Functions function) {
        x = abs(x);
        switch (function) {
            case Euclidean:
                return length(x);
            case Manhattan:
                return dot(x, float2(1.0));
            case Chebyshev:
                return max(x[0], x[1]);
        }
    }
}
