#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace ProgressiveBlur {
    constant int MAX_RADIUS = 100;
    constant int MAX_KERNEL_SIZE = 2 * MAX_RADIUS + 1;

    float gaussian(float x, float sigma) {
        return exp(-0.5 * x * x / (sigma * sigma)) / (sigma * sqrt(2.0 * M_PI_F));
    }

    void getKernel(int radius, float sigma, float _kernel[MAX_KERNEL_SIZE]) {
        float sum = 0.0;
        for (int i = -radius; i <= radius; i++) {
            int index = i + MAX_RADIUS;
            _kernel[index] = gaussian(float(i), sigma);
            sum += _kernel[index];
        }
        for (int i = MAX_RADIUS - radius; i <= MAX_RADIUS + radius; i++) {
            _kernel[i] /= sum;
        }
    }

    [[ stitchable ]] half4 main(
        float2 position,
        SwiftUI::Layer layer,
        float4 box,
        float radius
    ) {
        float ratio = min(max(position.y / box.w, 0.0), 1.0);
        radius = radius * smoothstep(0, 1, ratio);
        if (radius <= 0) {
            return layer.sample(position);
        }
        half4 sum = half4(0);
        const int offset = int(radius);
        const float sigma = radius / 3.0;
        float _kernel[MAX_KERNEL_SIZE];
        getKernel(offset, sigma, _kernel);
        for (int y = -offset; y <= offset; y++) {
            for (int x = -offset; x <= offset; x++) {
                float2 point = position + float2(x, y);
                sum += layer.sample(point)
                    * _kernel[y + MAX_RADIUS] * _kernel[x + MAX_RADIUS];
            }
        }
        return sum;
    }
}
