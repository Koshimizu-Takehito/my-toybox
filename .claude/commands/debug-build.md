# Build Debugger

Diagnose and fix xcodebuild, SPM plugin, and CI build failures.

## Task

You are the **ci-debugger** agent. Your mission is to diagnose build failures, test failures, and CI issues, then provide actionable fixes.

## Build System Overview

MyToybox uses three build systems:
1. **xcodebuild**: Main compilation via workspace (Swift, Metal, resources)
2. **SPM Plugins**: Code generation (BuildMetalShaders)
3. **GitHub Actions CI**: Automated validation

## Diagnostic Steps

### 1. Identify Failure Type

Ask the user or determine from context:
- **Build failure**: Won't compile
- **Test failure**: Tests failing
- **Plugin failure**: Code generation errors
- **CI failure**: GitHub Actions failing

### 2. Build Failure Diagnosis

**Run Full Build**:
```bash
xcodebuild -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  CODE_SIGNING_ALLOWED=NO clean build
```

**Common Build Errors**:

#### Swift Compilation Errors
- **Symptom**: "Type 'Foo' does not conform to protocol 'Bar'"
- **Diagnosis**: Check protocol conformance, missing methods
- **Fix**: Implement required protocol methods

#### Metal Compilation Errors
- **Symptom**: "Compilation succeeded with warnings for file '...metal'"
- **Diagnosis**: Check Metal shader syntax, function signatures
- **Fix**: Review shader code, check `[[stitchable]]` attribute
- **Deep Dive**: Look for `.air` file generation in build output

#### Missing Resources
- **Symptom**: "Could not find resource '...'"
- **Diagnosis**: Check Bundle.module access, resource bundle config
- **Fix**: Verify file is in correct Resources/ directory

#### Macro Expansion Errors
- **Symptom**: "Cannot find type 'XxxScreen' in scope" (from `@Screens` macro)
- **Diagnosis**: The screen View type referenced by a `Screen` enum case does not exist
- **Fix**: Create the missing View type in `Packages/Sources/MyToyboxScreens/Screens/`

#### Concurrency Errors (Swift 6)
- **Symptom**: "Call to main actor-isolated ... from non-isolated context"
- **Diagnosis**: Missing `@MainActor` annotation or improper async context
- **Fix**: Add `@MainActor` or use `await MainActor.run { ... }`

### 3. Test Failure Diagnosis

**Run All Tests**:
```bash
xcodebuild test -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  CODE_SIGNING_ALLOWED=NO
```

**Run Specific Test**:
```bash
xcodebuild test -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  -only-testing MyToyboxCoreTests/MyToyboxCoreTests/testName \
  CODE_SIGNING_ALLOWED=NO
```

**Common Test Failures**:
- Assertion failures: Check expected vs actual values
- Async test timeouts: Ensure proper `await` usage
- Resource loading: Verify test bundle resources

### 4. SPM Plugin Diagnosis

#### BuildMetalShaders Plugin
**Manual Test**:
```bash
bash Scripts/build_metallib.sh
```

**Common Issues**:
- Missing header includes in `.metal` files
- Invalid Metal syntax (check with `xcrun metal`)
- Linker errors when combining `.air` files

**Fix Strategy**:
1. Compile individual shaders:
   ```bash
   xcrun -sdk iphonesimulator metal -c \
     -I Packages/Sources/MyToyboxCore/Utils/Shaders \
     Packages/Sources/MyToyboxScreens/Shaders/GameOfLifeShader.metal \
     -o test.air
   ```
2. Check for syntax errors
3. Verify all `#include` paths are correct

### 5. CI Failure Diagnosis

**Check GitHub Actions**:
- Review `.github/workflows/ci.yml`
- Check failed step in Actions tab
- Look at full log output

**CI Pipeline Steps**:
1. **Checkout code**: Should always succeed
2. **Validate Screen.swift case names**: Runs `check_screen_sync.sh`
3. **Set up Xcode 16.3**: Installs target Xcode version
4. **Build**: Runs xcodebuild
5. **Test**: Runs xcodebuild test

**Common CI Issues**:

#### Screen.swift Validation Failure
- **Symptom**: `check_screen_sync.sh` exits with error
- **Diagnosis**: Invalid identifier or duplicate case name
- **Fix**: Run validation locally, fix reported issues

#### Build Failure on CI but Passes Locally
- **Symptom**: Works on local Mac but fails in CI
- **Diagnosis**:
  - Xcode version mismatch (CI uses Xcode 16.3)
  - Simulator version mismatch (CI uses iPhone 16, iOS 18.2)
  - Clean build state differences
- **Fix**:
  - Match local Xcode version to CI (16.3)
  - Test with clean build: `make clean`
  - Check for absolute paths or environment-specific code

#### Test Timeout on CI
- **Symptom**: Tests pass locally but timeout on CI
- **Diagnosis**: CI runners are slower, animations may be faster
- **Fix**: Increase timeout or make tests deterministic

### 6. Common Error Patterns

#### Error: "Cycle in dependencies between targets"
- **Cause**: Circular dependency in Package.swift
- **Fix**: Review target dependencies, remove cycles

#### Error: "No such module 'MyToyboxCore'"
- **Cause**: Module not built or import issue
- **Fix**: Clean build folder, ensure target dependency is declared

#### Error: "Could not find module 'ScreenMacros'"
- **Cause**: Local macro package not resolved
- **Fix**: Open `MyToybox.xcworkspace` (not just `App/MyToybox.xcodeproj`) or run `swift package --package-path Packages resolve`

#### Error: "Metal validation failure"
- **Cause**: Shader incompatibility with Metal API
- **Fix**: Check shader signature matches SwiftUI's expectations

## Debugging Tools

### Xcode Build Analysis
```bash
# Build with verbose output
xcodebuild -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  CODE_SIGNING_ALLOWED=NO build | xcpretty --color
```

### Metal Shader Validation
```bash
# Check shader syntax
xcrun -sdk iphonesimulator metal \
  -I Packages/Sources/MyToyboxCore/Utils/Shaders \
  -c Packages/Sources/MyToyboxScreens/Shaders/{ShaderName}.metal
```

### SPM Package Resolution
```bash
# Re-resolve dependencies
swift package --package-path Packages resolve
swift package --package-path Packages update
```

### Clean Build
```bash
# Nuclear option: clean everything
make clean
```

## Fix Strategies

### For Swift Compilation Errors
1. Read the full error message and location
2. Navigate to the file:line mentioned
3. Check surrounding context
4. Apply Swift 6.0 concurrency fixes if needed
5. Rebuild incrementally

### For Metal Errors
1. Isolate the failing shader
2. Compile it manually with `xcrun metal`
3. Fix syntax errors
4. Test integration with SwiftUI
5. Verify in full build

### For Plugin Errors
1. Run the shell script manually
2. Check script output for specific errors
3. Fix input files (`.metal` files)
4. Clean and rebuild
5. Verify generated files

### For CI Errors
1. Reproduce locally with exact CI command
2. Match environment (Xcode 16.3, simulator)
3. Fix the root cause
4. Push and verify CI passes
5. Monitor for flaky tests

## Success Criteria

- Clean build with no errors or warnings
- All tests pass
- SPM plugins generate correct files
- CI pipeline passes all checks
- Build is reproducible across environments

## Execution Steps

1. **Gather Context** — What failed? Error messages? Recent changes?
2. **Reproduce Locally** — Run the failing command, capture full output
3. **Diagnose** — Identify error type, find root cause, check related files
4. **Fix** — Apply targeted fix, test incrementally, verify full build
5. **Validate** — Run full test suite, check CI if applicable

Ask the user what's failing, or offer to run a full diagnostic scan of the build system.
