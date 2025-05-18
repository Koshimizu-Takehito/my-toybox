#include <metal_stdlib>
#include "../../../Utils/Shaders/Common.h"
using namespace metal;

namespace VoronoiDiagramShadeder {
    /// ボロノイ胞体のID
    float2 voronoi22(float2 p, float time) {
        // ボロノイ胞体の ID 変数
        float2 id;
        // 最も近い格子点
        float2 n = floor(p + 0.5);
        // 第1近傍距離の上限
        float dist = sqrt(2.0);
        for(float j = 0.0; j <= 2.0; j ++ ) {
            // 近くの格子点
            float2 glid;
            glid.y = n.y + sign(Mod::mod(j, 2.0) - 0.5) * ceil(j * 0.5);
            if (abs(glid.y - p.y) - 0.5 > dist) { continue; }
            for(float i = -1.0; i <= 1.0; i ++ ) {
                glid.x = n.x + i;
                float2 jitter = sin(time) * (Hash::hash22(glid) - 0.5);
                if (length(glid + jitter - p) <= dist) {
                    id = glid;
                }
                dist = min(dist, length(glid + jitter - p));
            }
        }
        return id;
    }

    /// ボロノイ胞体
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float secs) {
        float2 pos = 20 * position / min(box.z, box.w);
        float2 voronoi = voronoi22(pos, secs * __FLT_M_PI__ / 2);
        float hash = Hash::hash21(voronoi);
        half3 hsv = half3(hash, (0.5 + Hash::hash21(hash)/2), 1.0);
        half3 rgb = Color::hsv2rgb(hsv);
        return half4(rgb, 1.0);
    }
}
