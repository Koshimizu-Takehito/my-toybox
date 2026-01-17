# Documentation Syncer

Maintain and update project documentation across all files.

## Task

You are the **documentation-writer** agent. Your mission is to keep documentation accurate, synchronized, and helpful across README files, code comments, and project guides.

## Documentation Files

### Primary Documentation
1. **README.md** (English)
2. **README.ja.md** (Japanese)
3. **CLAUDE.md** (Claude Code instructions)

### Secondary Documentation
4. **Makefile** (inline help text)
5. **Package.swift** (package documentation)
6. **Screens.json** (screen descriptions)
7. **Code comments** (inline documentation)

## Sync Tasks

### 1. Update Screen Count

When screens are added/removed:

**Files to Update**:
- `README.md`: Update count in project description
- `README.ja.md`: Update count (Japanese version)
- `CLAUDE.md`: Update count if mentioned

**Example**:
```markdown
# Before
96+ visual effects screens

# After (when adding new screen)
97+ visual effects screens
```

### 2. Update Command Documentation

When Makefile commands change:

**Files to Update**:
- `README.md`: Command reference section
- `README.ja.md`: Command reference section
- `CLAUDE.md`: Build & Development Commands section

**Sync Steps**:
1. Read `Makefile` for all targets
2. Extract help text and descriptions
3. Update command tables in README files
4. Ensure examples match actual commands

**Example Makefile Target**:
```makefile
.PHONY: new-screen
new-screen:  ## Create new screen (interactive or with NAME=...)
	@bash Scripts/new_screen.sh $(NAME) $(SHADER)
```

**Corresponding Documentation**:
```markdown
| Command | Description |
|---------|-------------|
| `make new-screen` | Create new screen (interactive or with NAME=...) |
```

### 3. Update Architecture Documentation

When architecture changes:

**Files to Update**:
- `README.md`: Architecture section
- `CLAUDE.md`: Architecture section

**Key Areas**:
- Module structure changes
- New patterns introduced
- SPM plugin updates
- Build system changes

### 4. Update Build Instructions

When build commands or requirements change:

**Files to Update**:
- `README.md`: Build & Test section
- `README.ja.md`: Build & Test section (Japanese)
- `CLAUDE.md`: Build & Test (CI/Command-line) section

**Common Updates**:
- Xcode version requirements
- iOS/macOS deployment targets
- Simulator destinations
- New build flags

### 5. Update Git Conventions

When commit/PR guidelines change:

**Files to Update**:
- `CLAUDE.md`: Git Conventions section

**Key Information**:
- Conventional Commits format
- Branch strategy
- PR requirements

### 6. Sync English/Japanese Documentation

Keep README.md and README.ja.md synchronized:

**Process**:
1. Identify what changed in English version
2. Translate changes to Japanese (or ask user)
3. Apply to README.ja.md
4. Ensure structure matches

**Don't Auto-Translate**: Ask user for Japanese content if you're unsure

## Documentation Standards

### Conventional Commits

All documentation updates should use proper commit messages:

```
docs: update screen count to 97

docs: add /validate-screens command to README

docs(claude): update build instructions for Xcode 16.3

docs: sync Japanese README with English version
```

### Markdown Style

**Headings**:
```markdown
# Top Level (H1) - Project Title
## Section (H2) - Major sections
### Subsection (H3) - Detailed topics
```

**Code Blocks**:
````markdown
```bash
# Shell commands with syntax highlighting
make build
```

```swift
// Swift code examples
struct Example {}
```
````

**Tables**:
```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

**Links**:
```markdown
[Link Text](https://example.com)
[Relative Link](./docs/guide.md)
```

## Sync Checklist

### After Adding New Screen
- [ ] Increment screen count in README.md
- [ ] Increment screen count in README.ja.md
- [ ] Update Screens.json description is clear
- [ ] Ensure screen appears in app sidebar

### After Adding Makefile Command
- [ ] Add to README.md command table
- [ ] Add to README.ja.md command table
- [ ] Add to CLAUDE.md if relevant
- [ ] Add help text in Makefile: `## Description`

### After Architecture Change
- [ ] Update README.md architecture section
- [ ] Update CLAUDE.md architecture section
- [ ] Add inline code comments
- [ ] Update examples if needed

### After Dependency Update
- [ ] Update README.md dependencies section
- [ ] Update CLAUDE.md build requirements
- [ ] Note breaking changes if any
- [ ] Update CI documentation if affected

### After Build System Change
- [ ] Update all build command examples
- [ ] Update CLAUDE.md CI commands
- [ ] Update README.md build section
- [ ] Test all documented commands

## Documentation Review

### Accuracy Check
- [ ] All commands are correct and tested
- [ ] All file paths are accurate
- [ ] All code examples compile
- [ ] All links work

### Completeness Check
- [ ] All features are documented
- [ ] All commands have descriptions
- [ ] All requirements are listed
- [ ] All conventions are explained

### Consistency Check
- [ ] English and Japanese READMEs match structure
- [ ] Terminology is consistent across files
- [ ] Code style matches examples
- [ ] Formatting is uniform

### Clarity Check
- [ ] Instructions are clear and unambiguous
- [ ] Examples demonstrate actual usage
- [ ] Complex topics have enough detail
- [ ] Navigation is intuitive

## Documentation Templates

### New Command Documentation

**For README.md**:
```markdown
### `make command-name`

Brief description of what this command does.

**Usage**:
```bash
make command-name
make command-name ARG=value
```

**Options**:
- `ARG`: Description of argument

**Example**:
```bash
# Example usage
make command-name ARG=example
```
```

### New Screen Entry

**For Screens.json**:
```json
{
  "id": "newEffectScreen",
  "title": "New Effect",
  "description": "Brief description of the visual effect",
  "tags": ["animation", "metal"],
  "html": "https://github.com/Koshimizu-Takehito/my-toybox/tree/main/Packages/Sources/MyToyboxScreens/Screens/NewEffect"
}
```

### Architecture Documentation

**Template**:
```markdown
## Component Name

**Purpose**: What this component does

**Location**: `path/to/files`

**Key Features**:
- Feature 1
- Feature 2

**Example Usage**:
```swift
// Code example
```

**Related Components**:
- Component A
- Component B
```

## Sync Workflow

### 1. Identify Changes
- Scan recent commits for feature changes
- Check for new files/commands
- Review modified code

### 2. Determine Scope
- Which documentation files need updates?
- Is translation needed?
- Are examples required?

### 3. Update Documentation
- Make changes to all relevant files
- Keep structure consistent
- Add examples where helpful

### 4. Verify Updates
- Test all commands shown
- Check all links
- Verify code examples compile
- Ensure consistency across files

### 5. Commit Changes
- Use conventional commit message
- Reference related changes if applicable
- Keep documentation changes in separate commits

## Success Criteria

- All documentation is accurate and up-to-date
- English and Japanese versions are synchronized
- All examples work as shown
- All links are valid
- Documentation follows style guidelines
- Changes are committed with proper messages

## Execution Steps

1. **Scan for Outdated Documentation**
   - Check recent code changes
   - Compare docs to current implementation
   - List discrepancies

2. **Plan Updates**
   - Determine which files need changes
   - Identify translation needs
   - List specific updates

3. **Apply Updates**
   - Update README.md
   - Update README.ja.md (ask for translation if needed)
   - Update CLAUDE.md
   - Update other docs as needed

4. **Verify**
   - Test all documented commands
   - Check all links
   - Verify examples
   - Ensure consistency

5. **Commit**
   - Create commit with docs: prefix
   - Include clear description
   - Reference related changes

Ask the user what documentation needs updating, or offer to scan for outdated documentation.
