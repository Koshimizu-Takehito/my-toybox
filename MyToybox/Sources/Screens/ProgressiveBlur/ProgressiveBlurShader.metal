#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace ProgressiveBlur {
    /// Maximum blur radius supported by the kernel
    constant int MAX_RADIUS = 100;

    /// Max kernel size: for a radius of 100, kernel size = 201
    constant int MAX_KERNEL_SIZE = 2 * MAX_RADIUS + 1;

    /// Standard Gaussian function used to build blur kernel.
    float gaussian(float x, float sigma) {
        return exp(-0.5 * x * x / (sigma * sigma)) / (sigma * sqrt(2.0 * M_PI_F));
    }

    /// Generates a 1D Gaussian kernel normalized to a total sum of 1.
    void getKernel(int radius, float sigma, float _kernel[MAX_KERNEL_SIZE]) {
        float sum = 0.0;
        for (int i = -radius; i <= radius; i++) {
            int index = i + MAX_RADIUS;
            _kernel[index] = gaussian(float(i), sigma);
            sum += _kernel[index];
        }
        // Normalize the kernel
        for (int i = MAX_RADIUS - radius; i <= MAX_RADIUS + radius; i++) {
            _kernel[i] /= sum;
        }
    }

    /// Shader entry point: applies a separable 2D Gaussian blur
    /// whose intensity increases toward the bottom of the view.
    [[ stitchable ]] half4 main(
        float2 position,
        SwiftUI::Layer layer,
        float4 box,
        float radius
    ) {
        // Compute vertical progress: 0.0 (top) → 1.0 (bottom)
        float ratio = clamp(position.y / box.w, 0.0, 1.0);

        // Scale blur radius based on vertical position
        radius = radius * smoothstep(0, 1, ratio);

        // Skip blurring for radius = 0
        if (radius <= 0) {
            return layer.sample(position);
        }

        // Apply separable Gaussian blur
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
