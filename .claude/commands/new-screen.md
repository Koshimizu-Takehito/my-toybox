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

2. **Validate Naming**
   - Ensure screen name is UpperCamelCase
   - Convert to lowerCamelCase for the enum case ID (e.g., "ParticleExplosion" → "particleExplosionScreen")
   - Verify the ID doesn't already exist in `Packages/Sources/MyToyboxCatalog/Screen.swift`

3. **Update Screen.swift**
   - Read `Packages/Sources/MyToyboxCatalog/Screen.swift`
   - Add new case to the `enum Screen` in lowerCamelCase with "Screen" suffix:
     ```swift
     case particleExplosionScreen
     ```
   - The `@Screens` and `@Metadatas` macros will automatically generate the required conformances

4. **Create SwiftUI View File**
   - Create directory: `Packages/Sources/Screens/{ScreenName}/`
   - Create file: `{ScreenName}Screen.swift`
   - Use this template:
     ```swift
     import SwiftUI

     @Metadata(title: "{Title}", description: "{Description}", tags: [{tags}])
     public struct {ScreenName}Screen: View {
         public init() {}

         public var body: some View {
             // TODO: Implement your view
         }
     }

     #Preview {
         {ScreenName}Screen()
     }
     ```

5. **Create Thumbnail File**
   - Create file: `{ScreenName}Screen+Thumbnail.swift` in the same directory
   - Every screen **must** provide a thumbnail — the default implementation returns an empty view
   - Use this template (no shader):
     ```swift
     import SwiftUI

     extension {ScreenName}Screen {
         @ViewBuilder
         static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
             // TODO: Implement thumbnail
             Text("{ScreenName}")
                 .font(.caption2)
                 .fontWeight(.bold)
         }
     }

     #Preview {
         {ScreenName}Screen.thumbnail
             .colorScheme(.dark)
     }
     ```

6. **Create Metal Shader (if requested)**
   - Create file: `Packages/Sources/Screens/{ScreenName}/Shaders/{ScreenName}Shader.metal`
   - Use this template:
     ```metal
     #include <metal_stdlib>
     #include <SwiftUI/SwiftUI_Metal.h>
     using namespace metal;

     [[stitchable]] half4 {functionName}(
         float2 position,
         half4 color,
         float time
     ) {
         // TODO: Implement shader effect
         return color;
     }
     ```
   - Update the thumbnail file to use the shader:
     ```swift
     extension {ScreenName}Screen {
         @ViewBuilder
         static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
             Rectangle()
                 .colorEffect(
                     ShaderLibrary.module.{functionName}(
                         .float(time)
                     )
                 )
         }
     }
     ```

7. **Run Validation Script**
   - Execute: `bash Scripts/check_screen_sync.sh`
   - Ensure no validation errors

## Key Conventions

- **Screen IDs**: Must be valid Swift identifiers in lowerCamelCase with "Screen" suffix
- **File Names**: UpperCamelCase with "Screen" suffix (e.g., `GameOfLifeScreen.swift`)
- **Thumbnail**: Every screen must override `thumbnail(isScrolling:time:)` — no empty thumbnails
- **Tags**: Only use: `layout`, `animation`, `metal`
- **Preview**: Always include `#Preview` macro
- **Public Access**: Struct and init must be `public` (screens live in their own SPM module under `Packages/Sources/Screens/`)
- **Shader Functions**: Use `[[stitchable]]` attribute and follow naming convention
- **@Metadata**: Attach to the screen struct to provide `title`, `description`, `tags`

## Error Handling

- If screen ID already exists, suggest an alternative name
- If build fails, diagnose Metal compilation errors or Swift syntax issues
- If validation fails, check Screen.swift formatting

## Success Criteria

- `Screen.swift` contains the new case
- SwiftUI view file compiles without errors
- Thumbnail file exists and provides a non-empty implementation
- Metal shader compiles (if created)
- `check_screen_sync.sh` passes
- Screen appears in app's sidebar when run

Begin by asking the user for the required information.
