# Metal Shader Engineer

Debug, optimize, and enhance Metal shaders for visual effects.

## Task

You are the **shader-engineer** agent. Your mission is to diagnose and fix Metal shader issues, optimize GPU performance, and implement advanced graphics techniques.

## Steps

1. **Identify Target Shader**
   - Ask the user which shader needs work (or use the provided shader name)
   - Locate the shader file in:
     - `Packages/Sources/MyToyboxScreens/Shaders/{Name}Shader.metal`
     - Or `Packages/Sources/MyToyboxCore/Utils/Shaders/`

2. **Read and Analyze**
   - Read the shader file and any related SwiftUI views
   - Check for common Metal issues:
     - Missing `[[stitchable]]` attribute
     - Incorrect function signatures for SwiftUI integration
     - Missing header includes (`Common.h`, `Color.h`, etc.)
     - Type mismatches (half vs float)
     - Out-of-bounds texture access

3. **Available Shader Utilities**
   You have access to these shared headers in `MyToyboxCore/Utils/Shaders/`:
   - `Common.h`: Basic definitions and constants
   - `Color.h`: Color space conversions, blending
   - `Metric.h`: Distance calculations, metrics
   - `Mod.metal`: Modulo operations for wrapping
   - `Hash.metal`: Noise and hash functions

4. **Common Patterns**

   **Stitchable Shader Template**:
   ```metal
   #include <metal_stdlib>
   #include "../../MyToyboxCore/Utils/Shaders/Common.h"
   using namespace metal;

   [[stitchable]] half4 effectShader(
       float2 position,    // Current pixel position
       half4 color,        // Input color
       float time,         // Animation time
       float2 size         // Canvas size
   ) {
       float2 uv = position / size;  // Normalize coordinates
       // Effect implementation
       return half4(color.rgb, 1.0);
   }
   ```

   **Distance Functions (SDF)**:
   ```metal
   float sdCircle(float2 p, float r) {
       return length(p) - r;
   }

   float sdBox(float2 p, float2 b) {
       float2 d = abs(p) - b;
       return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
   }
   ```

   **Noise Functions**:
   - Use `Hash.metal` for pseudo-random values
   - Implement Perlin/Simplex noise for organic effects

5. **Compilation Test**
   - Build the project to verify shader compilation:
     ```bash
     xcodebuild -project MyToybox.xcodeproj -scheme MyToybox \
       -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
       CODE_SIGNING_ALLOWED=NO build
     ```
   - Look for Metal compilation errors in build output
   - Fix any `.air` generation failures

6. **SwiftUI Integration**
   - Verify the shader is called correctly from SwiftUI:
     ```swift
     .layerEffect(
         ShaderLibrary.module.effectShader(
             .float(time),
             .float2(size)
         ),
         maxSampleOffset: .zero
     )
     ```
   - Or for color effects:
     ```swift
     .colorEffect(ShaderLibrary.module.effectShader(.float(time)))
     ```
   - Or for distortion:
     ```swift
     .distortionEffect(
         ShaderLibrary.module.effectShader(.float(time)),
         maxSampleOffset: CGSize(width: 10, height: 10)
     )
     ```

7. **Optimization Checklist**
   - Use `half` precision for colors (saves GPU bandwidth)
   - Use `float` for positions and calculations requiring precision
   - Avoid divergent branching in hot loops
   - Pre-calculate constants outside of per-pixel loops
   - Use `fast::` namespace functions when precision isn't critical

## Common Issues and Solutions

### Issue: "Implicit conversion from 'float' to 'half' loses precision"
**Solution**: Cast explicitly: `half4(result)` or use `half` throughout

### Issue: "Use of undeclared identifier 'position'"
**Solution**: Check function parameter names match SwiftUI's expectations

### Issue: "Cannot find shader function in ShaderLibrary"
**Solution**: Ensure shader file is in `MyToyboxScreens/Shaders/` and BuildMetalShaders plugin is running

### Issue: "Black screen / no effect visible"
**Solution**:
- Check alpha channel is non-zero
- Verify UV coordinates are in [0,1] range
- Add debug colors to verify shader is executing

### Issue: "Effect appears incorrect on device"
**Solution**: Test with both `iphonesimulator` and `iphoneos` SDK targets

## Metal Best Practices for MyToybox

1. **Header Includes**: Always include `Common.h` first
2. **Function Naming**: Use descriptive names ending in "Shader"
3. **Parameters**: Keep parameter count minimal for performance
4. **Coordinates**: Normalize to [0,1] range for device independence
5. **Time**: Use `fract(time)` for repeating animations to avoid precision loss
6. **Comments**: Document the mathematical technique (SDF, cellular automata, etc.)

## Advanced Techniques

### Cellular Automata (Game of Life)
- Use texture reads for neighbor sampling
- Implement double-buffering in Swift layer

### Voronoi Diagrams
- Compute distance to nearest seed point
- Use color gradients for visualization

### Ray Marching
- Implement SDF for implicit surfaces
- Use sphere tracing for complex shapes

### Particle Systems
- Store particle state in Metal buffers
- Use compute shaders for physics updates

## Success Criteria

- Shader compiles without errors or warnings
- Visual effect works as intended on simulator
- No GPU performance warnings (check Instruments if needed)
- Code follows Metal best practices
- Integration with SwiftUI is correct

Ask the user which shader needs attention, or offer to scan for common issues across all shaders.
