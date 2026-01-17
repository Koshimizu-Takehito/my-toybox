# New Screen Creator

Create a new visual effects screen for MyToybox with all required files and metadata.

## Task

You are the **screen-creator** agent. Your mission is to create a complete, build-ready screen implementation following MyToybox's conventions.

## Steps

1. **Gather Requirements**
   - Ask the user for the screen name (UpperCamelCase, e.g., "ParticleExplosion")
   - Ask which tags apply: `layout`, `animation`, `metal` (can be multiple)
   - Ask if a Metal shader is needed (yes/no)
   - Ask for a brief description (English or Japanese)
   - Optionally ask for GitHub source URL

2. **Validate Naming**
   - Ensure screen name is UpperCamelCase
   - Convert to lowerCamelCase for the ID (e.g., "ParticleExplosion" → "particleExplosionScreen")
   - Verify the ID doesn't already exist in `Packages/Sources/MyToyboxScreens/Resources/Screens.json`

3. **Update Screens.json**
   - Read `Packages/Sources/MyToyboxScreens/Resources/Screens.json`
   - Add new entry to the JSON array:
     ```json
     {
       "id": "particleExplosionScreen",
       "title": "Particle Explosion",
       "description": "パーティクル爆発エフェクト",
       "tags": ["animation", "metal"],
       "html": "https://github.com/..."
     }
     ```
   - Ensure valid JSON formatting

4. **Create SwiftUI View File**
   - Create directory: `Packages/Sources/MyToyboxScreens/Screens/{ScreenName}/`
   - Create file: `{ScreenName}Screen.swift`
   - Use this template:
     ```swift
     import SwiftUI

     public struct {ScreenName}Screen: View {
         public init() {}

         public var body: some View {
             TimelineView(.animation) { context in
                 Canvas { context, size in
                     // Implementation here
                 }
             }
             .navigationTitle("{Title}")
         }
     }

     #Preview {
         {ScreenName}Screen()
     }
     ```

5. **Create Metal Shader (if requested)**
   - Create file: `Packages/Sources/MyToyboxScreens/Shaders/{ScreenName}Shader.metal`
   - Use this template:
     ```metal
     #include <metal_stdlib>
     #include "../../MyToyboxCore/Utils/Shaders/Common.h"
     using namespace metal;

     [[stitchable]] half4 {functionName}Shader(
         float2 position,
         half4 color,
         float time
     ) {
         // Shader implementation
         return color;
     }
     ```
   - Update SwiftUI view to use the shader:
     ```swift
     .layerEffect(
         ShaderLibrary.module.{functionName}Shader(.float(time)),
         maxSampleOffset: .zero
     )
     ```

6. **Verify Build**
   - Run: `xcodebuild -project MyToybox.xcodeproj -scheme MyToybox -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' CODE_SIGNING_ALLOWED=NO clean build`
   - Check that the GenerateScreenID plugin generates the new enum case
   - Check that Metal shaders compile (if applicable)

7. **Run Validation Script**
   - Execute: `bash Scripts/check_screen_sync.sh`
   - Ensure no validation errors

## Key Conventions

- **Screen IDs**: Must be valid Swift identifiers in lowerCamelCase with "Screen" suffix
- **File Names**: UpperCamelCase with "Screen" suffix (e.g., `GameOfLifeScreen.swift`)
- **Tags**: Only use: `layout`, `animation`, `metal`
- **Preview**: Always include `#Preview` macro
- **Public Access**: Struct and init must be `public`
- **Shader Functions**: Use `[[stitchable]]` attribute and follow naming convention

## Error Handling

- If screen ID already exists, suggest an alternative name
- If build fails, diagnose Metal compilation errors or Swift syntax issues
- If validation fails, check Screens.json formatting

## Success Criteria

- Screens.json contains valid new entry
- SwiftUI view file compiles without errors
- Metal shader compiles (if created)
- `check_screen_sync.sh` passes
- Screen appears in app's sidebar when run

Begin by asking the user for the required information.
