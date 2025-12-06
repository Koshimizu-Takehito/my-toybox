#ifndef Color_h
#define Color_h

namespace Color {
    /// HSV -> RGB
    half3 hsv2rgb(half3 c);
    /// RGB -> HSV
    half3 rgb2hsv(half3 c);
} // namespace Color

#endif /* Color_h */
