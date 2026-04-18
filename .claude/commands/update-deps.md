# Dependency Updater

Manage and update external dependencies and development tools.

## Task

You are the **dependency-updater** agent. Your mission is to keep external dependencies, development tools, and language versions up-to-date while maintaining compatibility.

## Dependencies Overview

### Swift Package Manager Dependencies

**Location**: `Packages/Package.swift`

**Current Dependencies**:
1. **ScreenMacros** (v1.0.0+)
   - GitHub: `Koshimizu-Takehito/ScreenMacros`
   - Purpose: `@Screens` macro for enum-to-View conversion
   - Type: External package

2. **ScreenMetadataMacros** (local)
   - Path: `../ScreenMetadataMacros`
   - Purpose: `@ScreenMetadata` attached macro
   - Type: Local package

### Development Tools

**Location**: `Mintfile`

**Current Tools**:
1. **SwiftLint** (v0.63.0)
   - `realm/SwiftLint@0.63.0`
   - Purpose: Code linting

2. **SwiftFormat** (v0.58.7)
   - `nicklockwood/SwiftFormat@0.58.7`
   - Purpose: Code formatting

### Build Requirements

- **Swift**: 6.3+
- **Xcode**: 26.4.1+ (CI uses 26.4)
- **iOS**: 18.0+
- **macOS**: 15.0+

## Update Strategies

### 1. Check for Updates

**SPM Dependencies**:
```bash
# List outdated packages
swift package show-dependencies

# Update to latest versions
swift package update
```

**Mint Tools**:
```bash
# Check latest releases on GitHub
# - https://github.com/realm/SwiftLint/releases
# - https://github.com/nicklockwood/SwiftFormat/releases
```

**Manual Check**:
- Visit GitHub repositories
- Check release notes
- Review breaking changes

### 2. Update SPM Dependencies

#### Update ScreenMacros

**Steps**:
1. Check latest version on GitHub:
   ```bash
   # Visit: https://github.com/Koshimizu-Takehito/ScreenMacros/releases
   ```

2. Read Package.swift:
   ```bash
   # Look for:
   .package(url: "https://github.com/Koshimizu-Takehito/ScreenMacros.git", from: "1.0.0")
   ```

3. Update version:
   - Edit `Packages/Package.swift`
   - Change version: `from: "1.0.0"` → `from: "2.0.0"`
   - Or use specific version: `.exact("2.0.0")`
   - Or use branch: `.branch("main")`

4. Resolve dependencies:
   ```bash
   swift package resolve
   swift package update ScreenMacros
   ```

5. Test build:
   ```bash
   xcodebuild -workspace MyToybox.xcworkspace -scheme MyToybox \
     -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' \
     CODE_SIGNING_ALLOWED=NO build
   ```

6. Check for breaking changes:
   - Review release notes
   - Update code if needed
   - Run tests

#### Update Local ScreenMetadataMacros

**Steps**:
1. Navigate to `ScreenMetadataMacros/`
2. Update dependencies in its `Package.swift`
3. Most commonly: Update Swift Syntax version
4. Rebuild the macro package

### 3. Update Mint Tools

#### Update SwiftLint

**Steps**:
1. Check latest version:
   ```bash
   # Visit: https://github.com/realm/SwiftLint/releases
   ```

2. Review release notes for:
   - New rules
   - Deprecated rules
   - Breaking changes
   - Swift version requirements

3. Update Mintfile:
   ```
   realm/SwiftLint@0.63.0  →  realm/SwiftLint@0.64.0
   ```

4. Update installed version:
   ```bash
   mint bootstrap  # Reinstall tools from Mintfile
   ```

5. Update configuration:
   - Check `.swiftlint.yml` for deprecated rules
   - Add new opt-in rules if beneficial
   - Test: `make lint`

6. Fix any new violations:
   ```bash
   make lint-fix
   ```

#### Update SwiftFormat

**Steps**:
1. Check latest version:
   ```bash
   # Visit: https://github.com/nicklockwood/SwiftFormat/releases
   ```

2. Review release notes for:
   - New formatting rules
   - Changed defaults
   - Swift version support

3. Update Mintfile:
   ```
   nicklockwood/SwiftFormat@0.58.7  →  nicklockwood/SwiftFormat@0.59.0
   ```

4. Reinstall:
   ```bash
   mint bootstrap
   ```

5. Test formatting:
   ```bash
   make format-check
   ```

6. If changes detected, review and apply:
   ```bash
   make format
   ```

### 4. Update Swift/Xcode Requirements

#### Update Swift Tools Version

**File**: `Packages/Package.swift`

**Current**: `swift-tools-version: 6.0`

**Steps**:
1. Check latest Swift version
2. Update Package.swift:
   ```swift
   // swift-tools-version: 6.1
   ```
3. Update platforms if needed:
   ```swift
   platforms: [
       .iOS(.v18),
       .macOS(.v15),
   ]
   ```
4. Test full build

#### Update Xcode CI Version

**File**: `.github/workflows/ci.yml`

**Current**: `macos-26` with Xcode 26.4

**Steps**:
1. Check available GitHub Actions runners
2. Update workflow:
   ```yaml
   runs-on: macos-26  # Current runner
   ```
3. Update Xcode version selection if needed:
   ```yaml
   - name: Set up Xcode 26.4
     uses: maxim-lobanov/setup-xcode@v1
     with:
       xcode-version: '26.4'
   ```
4. Update simulator destination:
   ```bash
   -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4'
   ```
5. Push and verify CI passes

### 5. Dependency Security Updates

**Check for vulnerabilities**:
```bash
# Review GitHub security advisories
# Check Dependabot alerts (if enabled)
```

**Immediate action if vulnerability found**:
1. Update affected dependency ASAP
2. Test thoroughly
3. Deploy fix
4. Document in commit message

## Update Checklist

### Before Update
- [ ] Read release notes for all updates
- [ ] Check for breaking changes
- [ ] Review migration guides
- [ ] Backup current working state (git commit)

### During Update
- [ ] Update Package.swift or Mintfile
- [ ] Run `swift package update` or `mint bootstrap`
- [ ] Update configuration files (.swiftlint.yml, .swiftformat)
- [ ] Build project
- [ ] Run tests
- [ ] Run quality checks (lint, format)

### After Update
- [ ] Fix any new errors or warnings
- [ ] Update documentation if needed
- [ ] Test app functionality manually
- [ ] Verify CI passes
- [ ] Create PR with conventional commit message

## Update Report Format

```
# Dependency Update Report

## Updates Applied

### SPM Dependencies
✓ ScreenMacros: 1.0.0 → 1.1.0
  - Added new @ScreenGroup macro
  - No breaking changes

### Development Tools
✓ SwiftLint: 0.63.0 → 0.64.0
  - 5 new rules available
  - Deprecated: unused_closure_parameter
  - Applied auto-fixes: 12 files

✓ SwiftFormat: 0.58.7 → 0.59.0
  - New rule: modernizeAttributeStyle
  - Formatted 8 files

## Build Status
✓ Clean build successful
✓ All tests passing (15/15)
✓ Quality checks passing

## Configuration Changes
- Updated .swiftlint.yml: Removed deprecated rule
- No .swiftformat changes needed

## Breaking Changes
None

## Recommendations
- Consider adopting new SwiftLint rule: explicit_type_interface
- Review formatted files for unintended changes
```

## Common Update Issues

### Issue: Build fails after dependency update
**Diagnosis**: API breaking change
**Fix**: Review migration guide, update code to new API

### Issue: New lint warnings flood the output
**Diagnosis**: New rule enabled by default
**Fix**: Disable rule temporarily, plan gradual adoption

### Issue: SwiftFormat changes style unexpectedly
**Diagnosis**: New default behavior
**Fix**: Add explicit rule to .swiftformat to preserve old behavior

### Issue: SPM resolution conflict
**Diagnosis**: Dependency version incompatibility
**Fix**: Check compatibility matrix, use specific versions

## Success Criteria

- All dependencies updated to specified versions
- Project builds without errors
- All tests pass
- Quality checks pass
- CI pipeline passes
- No regressions in functionality
- Documentation updated if needed

## Execution Steps

1. **Inventory Current Versions**
   - Read Package.swift
   - Read Mintfile
   - Note current versions

2. **Check for Updates**
   - Visit GitHub repos
   - Read release notes
   - Note available versions

3. **Plan Update**
   - Identify which to update
   - Check for breaking changes
   - Determine update order

4. **Apply Updates**
   - Update one dependency at a time
   - Test after each update
   - Fix issues before proceeding

5. **Validate**
   - Full build
   - All tests
   - Quality checks
   - CI verification

6. **Document**
   - Create commit with changes
   - Update CHANGELOG if exists
   - Note any breaking changes

Ask the user which dependencies to update, or offer to check all for available updates.
