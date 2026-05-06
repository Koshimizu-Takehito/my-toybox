#ifndef Metric_h
#define Metric_h

namespace Metric {
    /// 距離関数
    enum Functions {
        // ユークリッド距離
        Euclidean,
        // マンハッタン距離
        Manhattan,
        // チェビシェフ距離
        Chebyshev
    };

    float length2(float2 x, Functions function);
}

#endif /* Metric_h */
