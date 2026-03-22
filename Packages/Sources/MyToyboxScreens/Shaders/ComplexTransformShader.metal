/// =============================================================================
/// ComplexTransformShader.metal
/// =============================================================================
///
/// 概要
/// ----
/// 複素数値関数 f: ℂ → ℂ を「座標の非線形変換」と見なし、
/// 元の複素平面上の整数格子 (Re z = n, Im z = m) が f(z) によって
/// どのように歪むかを可視化するシェーダ。
///
///
/// 数学的背景: 複素関数と平面の非線形変換
/// ----------------------------------------
/// 複素平面 ℂ 上の関数 f(z) は、実2次元平面 ℝ² 上の写像
///
///     f: (x, y) ↦ (u(x,y), v(x,y))     ただし z = x + iy, f(z) = u + iv
///
/// と同一視できる。元の平面に引かれた格子線(直線群)は、f による
/// 像として曲線群に写される。この曲線群の形状から、関数の局所的な
/// 性質——回転・拡大・特異点の位置——を直観的に読み取ることができる。
///
/// 正則関数 (holomorphic function) の場合、Cauchy–Riemann の関係式
///
///     ∂u/∂x = ∂v/∂y,  ∂u/∂y = −∂v/∂x
///
/// が成り立ち、格子線の像は互いに直交する曲線族を形成する（等角写像性）。
/// 特異点(極・分岐点)の近傍では格子線が集中・渦巻き・折り返しを示す。
///
///
/// 複素演算の実装
/// ==============
///
/// 本シェーダでは複素数 z = (x, y) を float2 で表現する。
/// ℝ² 上のベクトル演算として複素演算を実装する。
///

#include <metal_stdlib>
using namespace metal;

namespace ComplexTransform {

    // MARK: - Complex Arithmetic

    /// 複素数の乗法 (Complex Multiplication)
    /// -----------------------------------------------
    /// 定義:
    ///     (a + bi)(c + di) = (ac − bd) + (ad + bc)i
    ///
    /// 幾何学的意味:
    ///     極形式 z = r·e^{iθ} を用いると、乗法は
    ///         |z₁z₂| = |z₁|·|z₂|   (絶対値の積)
    ///         arg(z₁z₂) = arg(z₁) + arg(z₂)   (偏角の和)
    ///     すなわち「回転と拡大の合成」に対応する。
    inline float2 cmul(float2 a, float2 b) {
        return float2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
    }

    /// 複素数の除法 (Complex Division)
    /// -----------------------------------------------
    /// 定義:
    ///     a/b = a·b̄ / |b|²
    ///
    /// ここで b̄ = (b.x, −b.y) は b の複素共役、|b|² = b.x² + b.y² = dot(b, b)。
    ///
    /// 幾何学的意味:
    ///     乗法の逆操作であり、|a/b| = |a|/|b|, arg(a/b) = arg(a) − arg(b)。
    ///     分母 |b|² → 0 のとき極 (pole) が生じ、格子線が無限遠へ発散する。
    inline float2 cdiv(float2 a, float2 b) {
        float denom = dot(b, b);
        return float2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / denom;
    }

    /// 複素指数関数 (Complex Exponential)
    /// -----------------------------------------------
    /// 定義:
    ///     exp(z) = exp(x)·(cos(y) + i·sin(y))     [Euler の公式]
    ///
    /// 性質:
    ///   - 周期 2πi を持つ: exp(z + 2πi) = exp(z)
    ///   - 水平線 y = c は原点中心の螺旋（半径 e^x が x に伴い指数的に変化）に写る
    ///   - 垂直線 x = c は半径 e^c の円に写る
    ///   - 零点を持たない (∀z: exp(z) ≠ 0)
    ///   - 本質的特異点が z = ∞ に存在する
    inline float2 cexp(float2 z) {
        float r = exp(z.x);
        return float2(r * cos(z.y), r * sin(z.y));
    }

    /// 複素正弦関数 (Complex Sine)
    /// -----------------------------------------------
    /// 定義:
    ///     sin(z) = sin(x)·cosh(y) + i·cos(x)·sinh(y)
    ///
    /// 導出 (Euler の公式から):
    ///     sin(z) = (e^{iz} − e^{−iz}) / (2i)
    ///     展開すると sin(x+iy) = sin(x)cosh(y) + i·cos(x)sinh(y)
    ///
    /// 性質:
    ///   - 実軸上では通常の sin(x) に一致する
    ///   - |Im z| が大きいと |sin(z)| ~ e^{|y|}/2 と指数的に増大する
    ///   - 零点は z = nπ (n ∈ ℤ) のみ（すべて実軸上）
    ///   - 周期 2π を持つ: sin(z + 2π) = sin(z)
    inline float2 csin(float2 z) {
        return float2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
    }

    /// 複素整数べき乗 (Complex Integer Power)
    /// -----------------------------------------------
    /// 定義:
    ///     z^n = z · z · … · z   (n 回の複素乗法)
    ///
    /// 極形式での表現:
    ///     z = r·e^{iθ} のとき z^n = r^n · e^{inθ}
    ///     すなわち絶対値は n 乗され、偏角は n 倍される。
    ///
    /// 格子への影響:
    ///     n 次のべき乗写像は原点近傍で n 重被覆を形成し、
    ///     格子線が n 枚に分岐する様子が観察できる。
    inline float2 cpow_int(float2 z, int n) {
        float2 result = float2(1.0, 0.0);
        for (int i = 0; i < n; i++) {
            result = cmul(result, z);
        }
        return result;
    }

    // MARK: - Preset Functions

    /// プリセット関数の評価
    /// -----------------------------------------------
    /// 各プリセット関数の数学的特徴:
    ///
    /// [0] f(z) = z²
    ///     - 2次の等角写像。原点が2重零点。
    ///     - 格子は原点周りで2回巻き付く放物線状の曲線群に変換される。
    ///     - 直線 Re z = c は放物線 u = c² − v²/(4c²) に写る。
    ///
    /// [1] f(z) = 1/(1+z)
    ///     - Möbius 変換（一次分数変換）の特殊例。
    ///     - z = −1 に1位の極を持つ。
    ///     - 直線と円を直線と円に写す（円円対応）。
    ///     - 格子線は極の近傍で反転し、円弧状の曲線群を形成する。
    ///
    /// [2] f(z) = z³ − 1
    ///     - 3次多項式。零点は1の3乗根: z = 1, e^{2πi/3}, e^{4πi/3}。
    ///     - 原点近傍で3重被覆構造が現れる。
    ///     - Newton 法の収束領域との関連でフラクタル境界を生む。
    ///
    /// [3] f(z) = sin(z)
    ///     - 超越整関数。零点は z = nπ (n ∈ ℤ)。
    ///     - 虚軸方向に指数的に増大するため、格子が y 方向で急速に膨張する。
    ///     - 実軸上では周期的な振動パターンが観察できる。
    ///
    /// [4] f(z) = exp(z)
    ///     - 零点なし、本質的特異点が無限遠にある。
    ///     - 水平格子線 → 螺旋、垂直格子線 → 同心円。
    ///     - 半平面 Re z < 0 は単位円内部に、Re z > 0 は単位円外部に写る。
    ///
    /// [5] f(z) = z² + c  (c = −0.7 + 0.27i)
    ///     - Julia 集合を定義する二次写像の1ステップ。
    ///     - 臨界点 z = 0 の軌道が有界か否かで Julia 集合の連結性が決まる。
    ///     - c = −0.7 + 0.27i は連結な Julia 集合を与えるパラメータ。
    float2 evaluate(float2 z, int functionIndex) {
        switch (functionIndex) {
            case 0: // z²
                return cmul(z, z);
            case 1: // 1/(1+z)
                return cdiv(float2(1.0, 0.0), float2(1.0 + z.x, z.y));
            case 2: // z³ − 1
                return cpow_int(z, 3) - float2(1.0, 0.0);
            case 3: // sin(z)
                return csin(z);
            case 4: // exp(z)
                return cexp(z);
            case 5: // z² + c  (c = −0.7 + 0.27i)
                return cmul(z, z) + float2(-0.7, 0.27);
            default:
                return z;
        }
    }

    // MARK: - Main

    /// メインシェーダ関数
    /// -----------------------------------------------
    ///
    /// アルゴリズム概要:
    ///
    /// 1. 座標変換: ピクセル座標 → 正規化座標 → 複素平面座標 z
    ///
    /// 2. 関数評価: w = f(z)  (2つのプリセット間を線形補間してアニメーション)
    ///
    /// 3. Jacobian の数値計算 (有限差分法):
    ///    ∂w/∂x ≈ (f(z + εe₁) − f(z)) / ε
    ///    ∂w/∂y ≈ (f(z + εe₂) − f(z)) / ε
    ///
    ///    Jacobian 行列:
    ///        J = | ∂u/∂x  ∂u/∂y |
    ///            | ∂v/∂x  ∂v/∂y |
    ///
    ///    正則関数では Cauchy–Riemann の関係式により
    ///        J = | ∂u/∂x  −∂v/∂x |  = |f'(z)| · R(arg f'(z))
    ///            | ∂v/∂x   ∂u/∂x |
    ///    と等角写像の回転拡大行列に帰着する。
    ///
    /// 4. 格子線の描画:
    ///    w 空間での整数格子線 (Re w ∈ ℤ, Im w ∈ ℤ) までの距離を計算し、
    ///    Jacobian の勾配の大きさで閾値を補正することで、
    ///    z 空間上で均一なスクリーン幅の格子線を描画する。
    ///
    ///    具体的には、w 空間で格子線までの距離 d に対し、
    ///    z 空間でのスクリーン上の見かけの太さは d / |∇(w成分)| に比例する。
    ///    これを一定に保つため、閾値を |∇(w成分)| に比例させる。
    ///
    /// 5. アンチエイリアシング:
    ///    smoothstep による滑らかな遷移で格子線のエッジを処理する。
    ///    smoothstep(a, b, x) は x ∈ [a, b] で 0 → 1 に滑らかに遷移する
    ///    エルミート補間関数 3t² − 2t³ (t = (x−a)/(b−a))。
    ///
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float functionIndex) {
        // Step 1: ピクセル座標 → 正規化座標 uv ∈ [-1, 1]²
        //   アスペクト比を保持するため、短辺を基準にスケーリングする。
        float2 center = box.zw * 0.5;
        float minDim = min(box.z, box.w);
        float2 uv = (position - center) / (minDim * 0.5);

        // Step 1b: 正規化座標 → 複素平面座標 z ∈ [-scale, scale]²
        float scale = 3.0;
        float2 z = uv * scale;

        // Step 2: 複素関数の評価（プリセット間の線形補間によるアニメーション）
        //   functionIndex が非整数のとき、隣接する2つのプリセット関数を
        //   線形補間することで滑らかな遷移アニメーションを実現する。
        //     w = (1−t)·f_{idx0}(z) + t·f_{idx1}(z)
        int idx0 = clamp(int(floor(functionIndex)), 0, 5);
        int idx1 = clamp(idx0 + 1, 0, 5);
        float t = clamp(functionIndex - float(idx0), 0.0f, 1.0f);
        float2 w0 = evaluate(z, idx0);
        float2 w1 = evaluate(z, idx1);
        float2 w = mix(w0, w1, t);

        // Step 3: Jacobian の数値計算（前進差分法）
        //   ε = 0.001 × scale として、x方向・y方向の偏微分を近似する。
        //   ∂w/∂x ≈ (w(z + (ε,0)) − w(z)) / ε
        //   ∂w/∂y ≈ (w(z + (0,ε)) − w(z)) / ε
        float eps = 0.001 * scale;
        float2 wdx0 = mix(evaluate(z + float2(eps, 0), idx0), evaluate(z + float2(eps, 0), idx1), t);
        float2 wdy0 = mix(evaluate(z + float2(0, eps), idx0), evaluate(z + float2(0, eps), idx1), t);
        float2 dwdx = (wdx0 - w) / eps;
        float2 dwdy = (wdy0 - w) / eps;

        // Step 3b: 勾配ベクトルの大きさ
        //   ∇(Re w) = (∂u/∂x, ∂u/∂y)  → gradReLen = |∇(Re w)|
        //   ∇(Im w) = (∂v/∂x, ∂v/∂y)  → gradImLen = |∇(Im w)|
        //
        //   これらは w 空間での単位距離が z 空間でどれだけの距離に
        //   対応するかを表す。格子線の太さの補正に用いる。
        float gradReLen = length(float2(dwdx.x, dwdy.x));
        float gradImLen = length(float2(dwdx.y, dwdy.y));

        // Step 4: 格子線の検出
        //   w 空間における最近傍の整数格子線までの距離を計算する。
        //   dist = |w_component − round(w_component)|
        float distRe = abs(w.x - round(w.x));
        float distIm = abs(w.y - round(w.y));

        // Step 4b: スクリーン空間での均一な線幅の実現
        //   pixelSize: z 空間における1ピクセルの大きさ
        //   threshold = lineWidth × pixelSize × |∇(w成分)|
        //
        //   w 空間での距離 d が z 空間で d/|∇w| に縮小されるため、
        //   均一な線幅を得るには閾値を |∇w| 倍する必要がある。
        float pixelSize = scale * 2.0 / minDim;
        float lineWidth = 0.8;

        float threshRe = lineWidth * pixelSize * gradReLen;
        float threshIm = lineWidth * pixelSize * gradImLen;

        // Step 5: アンチエイリアシング付き格子線描画
        //   smoothstep で閾値の半分〜1.5倍の範囲で滑らかに遷移させる。
        //   線の内側 (dist < thresh*0.5) → 1.0 (完全に線)
        //   線の外側 (dist > thresh*1.5) → 0.0 (完全に背景)
        //   遷移帯域 → エルミート補間による滑らかなフェードアウト
        float lineRe = 1.0 - smoothstep(threshRe * 0.5, threshRe * 1.5, distRe);
        float lineIm = 1.0 - smoothstep(threshIm * 0.5, threshIm * 1.5, distIm);

        // Step 5b: 座標軸の描画（太い線）
        //   Re w = 0, Im w = 0 の軸を太めに描画して座標系を強調する。
        float axisWidth = 2.0;
        float threshAxisRe = axisWidth * pixelSize * gradReLen;
        float threshAxisIm = axisWidth * pixelSize * gradImLen;
        float axisRe = 1.0 - smoothstep(threshAxisRe * 0.5, threshAxisRe * 1.5, abs(w.x));
        float axisIm = 1.0 - smoothstep(threshAxisIm * 0.5, threshAxisIm * 1.5, abs(w.y));

        // Step 6: 色の合成
        //   Re 方向の格子線 → 青系（水平格子線の像）
        //   Im 方向の格子線 → 赤系（垂直格子線の像）
        //   座標軸は対応する色の濃い版で描画する。
        //
        //   合成順序: 背景 → 格子線 → 座標軸（後から描画したものが手前）
        half3 bg = half3(0.95h, 0.95h, 0.92h);
        half3 reColor = half3(0.2h, 0.45h, 0.8h);
        half3 imColor = half3(0.8h, 0.25h, 0.3h);
        half3 axisReColor = half3(0.1h, 0.25h, 0.55h);
        half3 axisImColor = half3(0.55h, 0.1h, 0.15h);

        half3 rgb = bg;
        rgb = mix(rgb, reColor, half(lineRe));
        rgb = mix(rgb, imColor, half(lineIm));
        rgb = mix(rgb, axisReColor, half(axisRe));
        rgb = mix(rgb, axisImColor, half(axisIm));

        return half4(rgb, 1.0h);
    }
}
