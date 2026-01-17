# MyToybox Claude Code Commands

Custom slash commands for efficient MyToybox development workflows.

## Available Commands

| Command | Description | Agent Role |
|---------|-------------|------------|
| `/new-screen` | Create a new visual effects screen | Screen Creator |
| `/fix-shader` | Debug and optimize Metal shaders | Shader Engineer |
| `/review-architecture` | Review code architecture and patterns | Architecture Advisor |
| `/validate-screens` | Validate Screens.json and implementations | Screen Validator |
| `/debug-build` | Diagnose build and CI failures | Build Debugger |
| `/quality-check` | Run SwiftLint and SwiftFormat checks | Quality Enforcer |
| `/update-deps` | Update dependencies and tools | Dependency Updater |
| `/sync-docs` | Synchronize project documentation | Documentation Syncer |

## Quick Start

### Creating a New Screen

```
/new-screen
```

The command will guide you through:
1. Naming your screen (e.g., "ParticleExplosion")
2. Selecting tags (layout/animation/metal)
3. Choosing whether to include Metal shader
4. Creating all necessary files
5. Validating the build

### Fixing Shader Issues

```
/fix-shader
```

Use when you encounter:
- Metal compilation errors
- Visual effects not appearing correctly
- Performance issues with GPU rendering
- SwiftUI shader integration problems

### Validating Project State

```
/validate-screens
```

Runs comprehensive checks:
- JSON structure validation
- Screen ID format verification
- Implementation file existence
- Orphaned file detection

### Debugging Build Failures

```
/debug-build
```

Diagnoses:
- Swift compilation errors
- Metal shader compilation failures
- SPM plugin issues
- CI/CD pipeline failures

### Checking Code Quality

```
/quality-check
```

Executes:
- SwiftLint validation
- SwiftFormat checking
- Auto-fixes when possible
- Generates quality report

### Reviewing Architecture

```
/review-architecture
```

Provides:
- MVVM pattern compliance review
- Swift 6.0 concurrency checks
- YAGNI principle enforcement
- Best practice recommendations

### Updating Dependencies

```
/update-deps
```

Manages:
- SPM package updates
- Mint tool updates (SwiftLint, SwiftFormat)
- Xcode/Swift version requirements
- Breaking change migration

### Syncing Documentation

```
/sync-docs
```

Maintains:
- README.md and README.ja.md synchronization
- Screen count updates
- Command documentation
- Architecture guides

## Command Usage Examples

### Example 1: Adding a New Particle Effect

```
User: I want to create a particle explosion effect with Metal shaders

You: /new-screen

[Command guides through creation process]

Result:
✓ Screens.json updated with particleExplosionScreen
✓ ParticleExplosionScreen.swift created
✓ ParticleExplosionShader.metal created
✓ Build successful
✓ Screen appears in app sidebar
```

### Example 2: Fixing a Build Error

```
User: Build is failing with Metal compilation errors

You: /debug-build

[Command analyzes build output]

Result:
✗ GameOfLifeShader.metal:15 - Missing [[stitchable]] attribute
✓ Applied fix
✓ Recompiled shader
✓ Build successful
```

### Example 3: Pre-Commit Quality Check

```
User: Check if my code is ready to commit

You: /quality-check

[Command runs lint and format checks]

Result:
✓ Auto-formatted 3 files
✓ Fixed 12 lint violations
✗ Manual fix needed: ExampleScreen.swift:42 (line too long)
[Provides specific guidance for manual fix]
```

## Command Philosophy

These commands embody specialized agent roles that:

1. **Follow MyToybox Conventions**
   - Understand project structure
   - Apply established patterns
   - Respect coding standards

2. **Automate Repetitive Tasks**
   - File creation boilerplate
   - JSON updates
   - Validation scripts

3. **Provide Expert Guidance**
   - Architecture best practices
   - Metal shader techniques
   - Swift 6.0 concurrency

4. **Maintain Quality**
   - Code formatting
   - Lint compliance
   - Documentation sync

5. **Prevent Over-Engineering**
   - YAGNI enforcement
   - Simplicity checks
   - Direct solutions

## Integration with Existing Tools

These commands complement existing Makefile targets:

| Make Command | Claude Command | When to Use |
|--------------|----------------|-------------|
| `make new-screen` | `/new-screen` | Use Claude for guided, interactive creation |
| `make lint` | `/quality-check` | Use Claude for comprehensive report + auto-fix |
| `make open` | N/A | Use Make to simply open Xcode |
| `make clean` | N/A | Use Make for quick cleanup |

**Rule of Thumb**:
- Use **Make** for simple, one-step operations
- Use **Claude commands** for multi-step workflows requiring analysis

## Customizing Commands

To modify a command:

1. Edit the corresponding `.md` file in `.claude/commands/`
2. Update instructions, steps, or examples
3. Changes take effect immediately (no restart needed)

Example:
```bash
# Edit the new-screen command
vim .claude/commands/new-screen.md
```

## Command Development

### Creating New Commands

1. **Identify Repetitive Workflow**
   - What task is done frequently?
   - Does it require multiple tools/steps?
   - Would automation save significant time?

2. **Define Agent Role**
   - What is this agent's mission?
   - What domain expertise does it need?
   - What are success criteria?

3. **Write Command File**
   - Create `.claude/commands/your-command.md`
   - Structure: Task → Steps → Examples → Success Criteria
   - Include error handling and common issues

4. **Test Thoroughly**
   - Run command in various scenarios
   - Verify error cases are handled
   - Ensure generated code/files are correct

5. **Document**
   - Add to this README
   - Include usage examples
   - Note any prerequisites

## Best Practices

### When Using Commands

1. **Trust the Agent**: Commands are designed to handle full workflows
2. **Provide Context**: Mention specific files or errors when relevant
3. **Review Changes**: Always review generated code before committing
4. **Iterate**: If result isn't perfect, provide feedback and re-run

### Command Invocation

**Good**:
```
/new-screen
/fix-shader GameOfLifeShader
/validate-screens
```

**Also Good** (with context):
```
I added 3 new screens and want to validate they're set up correctly
[Claude will use /validate-screens]

My Metal shader for voronoi diagrams isn't rendering
[Claude will use /fix-shader]
```

## Troubleshooting

### Command Doesn't Work

1. Check command is in `.claude/commands/` directory
2. Verify `.md` file is properly formatted
3. Try running Claude Code with `--verbose` flag

### Agent Makes Wrong Assumptions

- Provide more specific context in your request
- Mention files or error messages explicitly
- Guide the agent with additional details

### Generated Code Has Issues

- Review the command's instructions (edit `.md` file if needed)
- Provide feedback to refine the approach
- Report patterns of issues for command improvement

## Contributing

To suggest improvements to these commands:

1. Test your proposed change locally
2. Document the improvement
3. Create a PR with the updated command file
4. Include examples showing the improvement

## Learn More

- **Claude Code Documentation**: https://docs.claude.ai/claude-code
- **MyToybox Architecture**: See `CLAUDE.md`
- **Conventional Commits**: https://www.conventionalcommits.org/

---

**Quick Reference**: Type `/` in Claude Code to see all available commands.
