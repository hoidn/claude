# Claude Code: The Comprehensive Guide & Best Practices

> An authoritative, exhaustive documentation of Claude Code, Anthropic's official CLI for AI-powered software development

## Table of Contents

1. [Overview & Philosophy](#overview--philosophy)
2. [Installation & Setup](#installation--setup)
3. [Core Features & Capabilities](#core-features--capabilities)
4. [Common Workflows](#common-workflows)
5. [Anthropic's Proven Workflows](#anthropics-proven-workflows)
6. [How Anthropic Teams Use Claude Code](#how-anthropic-teams-use-claude-code)
7. [Slash Commands Reference](#slash-commands-reference)
8. [CLI Reference](#cli-reference)
9. [IDE Integrations](#ide-integrations)
10. [Settings & Configuration](#settings--configuration)
11. [Subagents](#subagents)
12. [Output Styles](#output-styles)
13. [Hooks](#hooks)
14. [GitHub Actions Integration](#github-actions-integration)
15. [Model Context Protocol (MCP)](#model-context-protocol-mcp)
16. [SDK Development](#sdk-development)
17. [Enterprise Deployment](#enterprise-deployment)
18. [Troubleshooting](#troubleshooting)
19. [Best Practices](#best-practices)

---

## Overview & Philosophy

### What is Claude Code?

Claude Code is an AI-powered CLI tool that integrates directly into your terminal, providing intelligent coding assistance through natural language interaction. It combines the power of Claude's language models with direct access to your development environment.

### Core Value Proposition

- **Build features from descriptions**: Describe what you want in plain English, and Claude Code creates a plan, writes the code, and ensures it works
- **Debug and fix issues**: Provide error messages or bug descriptions for automatic analysis and fixes
- **Navigate any codebase**: Ask questions about your codebase and get contextual, up-to-date answers
- **Automate tedious tasks**: Handle lint fixes, merge conflicts, release notes, and more with single commands

### Why Developers Choose Claude Code

1. **Terminal-Native**: Works where you already work, integrating with existing tools and workflows
2. **Action-Oriented**: Directly edits files, runs commands, and creates commits
3. **Unix Philosophy**: Composable and scriptable for complex workflows
4. **Enterprise-Ready**: Offers enterprise-grade security, privacy, and compliance

### Key Design Principles

- **Incremental Progress**: Small, compilable changes that pass tests
- **Learning from Code**: Studies existing patterns before implementing
- **Pragmatic Solutions**: Adapts to project reality over dogmatic approaches
- **Clear Intent**: Prioritizes obvious, boring solutions over clever tricks

---

## Installation & Setup

### Prerequisites

- **Node.js 18 or newer** (for NPM installation)
- **Claude.ai or Anthropic Console account** for authentication
- **Git** (recommended for version control features)

### Installation Methods

#### 1. NPM Installation (Recommended)

```bash
npm install -g @anthropic-ai/claude-code
```

#### 2. Native Installation

**macOS, Linux, WSL:**
```bash
# Install stable version
curl -fsSL https://claude.ai/install.sh | bash

# Install latest version
curl -fsSL https://claude.ai/install.sh | bash -s latest
```

**Windows PowerShell:**
```powershell
# Install stable version
irm https://claude.ai/install.ps1 | iex

# Install latest version
irm https://claude.ai/install.ps1 | iex -ArgumentList @('latest')
```

**Windows CMD:**
```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### Initial Setup

1. **Start Claude Code:**
   ```bash
   claude
   ```

2. **Authenticate:**
   ```bash
   /login
   # Follow prompts to authenticate with Claude.ai or Anthropic Console
   ```

3. **Verify Installation:**
   ```bash
   claude --version
   ```

### Configuration Files

Claude Code uses a hierarchical configuration system:

- **User-level**: `~/.claude/settings.json`
- **Project-level**: `.claude/settings.json`
- **Local settings**: `.claude/settings.local.json`

---

## Core Features & Capabilities

### Natural Language Interface

Claude Code understands natural language commands:

```bash
# Understanding codebase
> what does this project do?
> where is the authentication logic?
> explain the data flow in the payment system

# Making changes
> add error handling to the user registration function
> refactor this to use modern React hooks
> create unit tests for the authentication module

# Git operations
> commit my changes with a descriptive message
> create a new feature branch
> what files have I changed?
```

### File Operations

- **Read**: Examine file contents with line numbers
- **Edit**: Make precise replacements in files
- **Write**: Create new files with content
- **MultiEdit**: Perform multiple edits in a single operation
- **NotebookEdit**: Edit Jupyter notebook cells

### Command Execution

Claude Code can execute bash commands with:
- Timeout control (up to 10 minutes)
- Background execution support
- Output streaming
- Error handling

### Search & Discovery

- **Grep**: Powerful regex-based content search
- **Glob**: File pattern matching
- **Task**: Launch specialized agents for complex searches
- **WebSearch**: Search the web for current information
- **WebFetch**: Retrieve and analyze web content

### Todo Management

Track and organize complex tasks:

```bash
# Claude automatically creates todos for multi-step tasks
# Manual control available through TodoWrite tool
```

---

## Common Workflows

### 1. Project Understanding & Navigation

**Quick Onboarding to New Projects:**
```bash
> what technologies does this project use?
> what's the project structure?
> where is the main entry point?
```

**Finding Specific Code:**
```bash
> where is the user authentication implemented?
> find all API endpoints related to payments
> show me the database schema
```

### 2. Debugging & Problem Solving

**Error Resolution:**
```bash
> Error: Cannot read property 'map' of undefined at line 42
# Claude analyzes the error, identifies the issue, and implements a fix

> the login form isn't validating email addresses correctly
# Claude examines the validation logic and fixes the issue
```

**Performance Optimization:**
```bash
> analyze and optimize the database queries in the user service
> find and fix any memory leaks in the application
```

### 3. Feature Development

**Building from Descriptions:**
```bash
> add a dark mode toggle to the settings page
> implement pagination for the product listing
> create a REST API endpoint for user profiles
```

**Code Modernization:**
```bash
> update this class component to use React hooks
> convert callbacks to async/await
> migrate from webpack to vite
```

### 4. Documentation & Analysis

**Code Documentation:**
```bash
> add JSDoc comments to all public methods
> create a README for this module
> document the API endpoints
```

**Codebase Analysis:**
```bash
> analyze the test coverage and suggest improvements
> identify potential security vulnerabilities
> find code duplication and suggest refactoring
```

### 5. Git Workflow Integration

**Intelligent Commits:**
```bash
> stage my changes and create semantic commits
> create a PR with a comprehensive description
> resolve merge conflicts in the feature branch
```

### 6. Extended Thinking for Complex Tasks

For challenging problems requiring deep reasoning:
```bash
> think deeply about the architecture for a real-time notification system
> keep thinking about how to optimize this algorithm
> think a lot about potential edge cases in this payment flow
```

**Thinking Mode Trigger Words** (progressively more thinking budget):
- `think` - Basic extended thinking
- `think hard` - More computational resources
- `think harder` - Extensive reasoning
- `ultrathink` - Maximum thinking capability

---

## Anthropic's Proven Workflows

### Overview

These workflows have been developed and refined by Anthropic's engineering teams through extensive internal use of Claude Code.

### 1. Explore, Plan, Code, Commit Workflow

**Step 1: Explore**
```bash
> what files are related to authentication?
> show me how the payment processing works
> where is the database connection configured?
```

**Step 2: Plan**
```bash
> think hard about how to implement OAuth 2.0 in this system
> create a detailed plan for refactoring the user service
```

**Step 3: Code**
```bash
> implement the OAuth flow based on our plan
> refactor the user service following the plan
```

**Step 4: Commit**
```bash
> commit these changes with a descriptive message
> create a PR with comprehensive description
```

### 2. Test-Driven Development (TDD) Workflow

```bash
# 1. Write tests first
> write comprehensive tests for a user authentication service

# 2. Confirm tests fail
> run the tests to confirm they fail

# 3. Implement minimal code to pass
> implement just enough code to make the tests pass

# 4. Refactor with confidence
> refactor the implementation while keeping tests green
```

### 3. Visual Iteration Workflow

Perfect for UI development:

```bash
# 1. Provide design mock
> here's a screenshot of the desired UI [paste image]

# 2. Initial implementation
> implement this design using our component library

# 3. Take screenshot of result
> take a screenshot of the current implementation

# 4. Iterate
> adjust the spacing and colors to match the mock better
```

### 4. Parallel Development with Git Worktrees

```bash
# Set up worktrees for parallel tasks
> create a git worktree for the authentication feature
> create another worktree for the payment integration

# Work on multiple features simultaneously
# Each Claude instance works in isolation
```

### 5. Multi-Instance Verification

```bash
# Instance 1: Implementation
> implement the complex sorting algorithm

# Instance 2: Verification
> review this implementation for correctness and edge cases

# Instance 3: Performance testing
> write performance benchmarks for this algorithm
```

### 6. Customizing with CLAUDE.md

**Essential CLAUDE.md Elements**:

```markdown
# Project Guidelines

## Quick Commands
- Run tests: `npm test`
- Build: `npm run build`
- Deploy staging: `./scripts/deploy-staging.sh`

## Code Style
- Use functional components with hooks
- Prefer composition over inheritance
- All async functions must have error handling

## Architecture Decisions
- We use PostgreSQL with Prisma ORM
- Authentication via JWT tokens
- State management with Zustand

## Known Issues
- The legacy API client in `/src/api/v1` is deprecated
- Use `/src/api/v2` for all new features
```

### 7. Course Correction Techniques

**Early Intervention**:
```bash
# If Claude goes off track
> stop, let's approach this differently
> actually, focus on just the authentication part first
> /clear  # Start fresh when needed
```

**Multiple Input Methods**:
```bash
# Combine different data sources
> here's the error message [paste]
> and here's a screenshot of the issue [image]
> the logs show this pattern [paste logs]
```

---

## How Anthropic Teams Use Claude Code

### Engineering Teams

#### Infrastructure Team
- **Use Case**: Understanding complex data pipelines
- **Workflow**: Read CLAUDE.md → Ask about specific components → Implement changes
- **Result**: Rapid onboarding to unfamiliar systems

#### Security Engineering
- **Use Case**: Incident response and vulnerability analysis
- **Workflow**: Trace control flow → Identify attack vectors → Generate fixes
- **Result**: 80% reduction in research time

#### Product Engineering
- **Use Case**: Bug fixes in unfamiliar codebases
- **Workflow**: Describe bug → Claude identifies files → Implements fix with tests
- **Result**: Confidence in modifying complex systems

### Non-Technical Teams

#### Product Design
- **Use Case**: Building functional prototypes
- **Workflow**: Describe feature → Claude implements → Iterate visually
- **Result**: Designers ship production features independently

#### Data Science
- **Use Case**: Creating React visualizations
- **Workflow**: Provide data → Describe visualization → Claude builds components
- **Result**: No deep TypeScript knowledge required

#### Growth Marketing
- **Use Case**: Generating ad variations
- **Workflow**: Define template → Claude creates variations → A/B test
- **Result**: Automated creative generation

#### Legal Team
- **Use Case**: Building automation tools
- **Workflow**: Describe process → Claude builds prototype → Iterate
- **Result**: Custom "phone tree" systems without coding

### Key Insights from Anthropic's Usage

1. **Context is King**: CLAUDE.md files dramatically improve effectiveness
2. **Start Small**: Begin with codebase Q&A before attempting changes
3. **Trust but Verify**: Use multiple instances for critical code
4. **Non-Technical Empowerment**: Claude Code dissolves technical barriers
5. **Research Acceleration**: 80% time savings on investigation tasks

---

## Slash Commands Reference

### Built-in Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/add-dir` | Add additional working directories | `/add-dir /path/to/directory` |
| `/agents` | Manage custom AI subagents | `/agents` |
| `/bug` | Report bugs to Anthropic | `/bug [description]` |
| `/clear` | Clear conversation history | `/clear` |
| `/compact` | Compact conversation context | `/compact [focus_area]` |
| `/config` | View/modify configuration | `/config` or `/config --global` |
| `/cost` | Show token usage and costs | `/cost` |
| `/doctor` | Check installation health | `/doctor` |
| `/help` | Get usage help | `/help` |
| `/init` | Initialize project with CLAUDE.md | `/init` |
| `/install-github-app` | Set up GitHub integration | `/install-github-app` |
| `/login` | Switch Anthropic accounts | `/login` |
| `/logout` | Sign out of account | `/logout` |
| `/mcp` | Manage MCP servers | `/mcp list` or `/mcp auth [server]` |
| `/memory` | Edit CLAUDE.md files | `/memory` |
| `/model` | Select or change AI model | `/model` |
| `/output-style` | Change output style | `/output-style [style]` |
| `/permissions` | View/update access permissions | `/permissions` |
| `/pr_comments` | View PR comments | `/pr_comments` |
| `/review` | Request code review | `/review` |
| `/status` | View account and system status | `/status` |
| `/terminal-setup` | Install key bindings | `/terminal-setup` |
| `/vim` | Enter vim mode | `/vim` |

### Custom Slash Commands

#### Creating Project Commands

```bash
# Create command directory
mkdir -p .claude/commands

# Create simple command
echo "Analyze this code for security issues:" > .claude/commands/security.md

# Create command with arguments
cat > .claude/commands/test.md << 'EOF'
---
name: test
description: Run tests with options
---

Run the test suite with these parameters: $ARGUMENTS
Focus on: $1
Verbose mode: $2
EOF
```

#### Creating User Commands

```bash
# User-level commands (available across projects)
mkdir -p ~/.claude/commands
echo "Generate comprehensive documentation:" > ~/.claude/commands/document.md
```

#### Command with Frontmatter

```markdown
---
name: optimize
description: Optimize code for performance
tags: [performance, optimization]
---

Analyze the following code for performance bottlenecks:
- Memory usage
- Time complexity
- Database queries
- Caching opportunities

File: @$1
```

### MCP Server Commands

MCP servers can add their own slash commands:

```bash
# Format: /mcp__[server]__[command]
/mcp__github__create_issue
/mcp__linear__list_tickets
/mcp__postgres__query
```

---

## CLI Reference

### Basic Commands

```bash
# Start interactive REPL
claude

# Start with initial prompt
claude "explain this codebase"

# Non-interactive query
claude -p "fix the type errors"

# Pipe input
cat error.log | claude -p "diagnose these errors"

# Continue most recent conversation
claude -c
claude --continue

# Resume specific session
claude -r "550e8400-e29b-41d4" "continue the refactoring"
claude --resume "550e8400-e29b-41d4"

# Update Claude Code
claude update
```

### Configuration Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--add-dir` | Add working directories | `--add-dir /path/to/dir` |
| `--allowedTools` | Specify allowed tools | `--allowedTools "Read,Grep"` |
| `--disallowedTools` | Block specific tools | `--disallowedTools "Bash,Edit"` |
| `--model` | Set AI model | `--model claude-3-5-sonnet` |
| `--max-turns` | Limit conversation turns | `--max-turns 5` |
| `--permission-mode` | Set permission mode | `--permission-mode acceptEdits` |
| `--output-format` | Output format | `--output-format json` |
| `--verbose` | Enable detailed logging | `--verbose` |
| `--cwd` | Set working directory | `--cwd /project/path` |
| `--system-prompt` | Override system prompt | `--system-prompt "You are..."` |
| `--append-system-prompt` | Add to system prompt | `--append-system-prompt "Also..."` |

### Output Formats

```bash
# Text output (default)
claude -p "explain the architecture"

# JSON output
claude -p "analyze dependencies" --output-format json

# Streaming JSON
claude -p "refactor this code" --output-format stream-json
```

### Permission Modes

```bash
# Ask for permission (default)
claude -p "fix bugs" --permission-mode ask

# Auto-accept file edits
claude -p "refactor" --permission-mode acceptEdits

# Auto-accept all actions
claude -p "implement feature" --permission-mode acceptAll

# Dangerous: skip all permissions
claude -p "urgent fix" --dangerously-skip-permissions
```

### Scripting Examples

```bash
#!/bin/bash
# Automated code review
review_pr() {
    local pr_diff="$(git diff main...HEAD)"
    echo "$pr_diff" | claude -p "Review this code for:
        - Security issues
        - Performance problems
        - Best practices
        - Test coverage" \
        --output-format json \
        --allowedTools "Read,Grep"
}

# Continuous monitoring
tail -f application.log | claude -p "Alert on errors or anomalies" \
    --allowedTools "WebSearch" \
    --max-turns 100
```

### Configuration Management

```bash
# List all configuration
claude config list

# Get specific setting
claude config get model

# Set configuration value
claude config set model claude-3-5-sonnet

# Add to array configuration
claude config add allowedTools "WebSearch"

# Remove from array
claude config remove disallowedTools "Edit"
```

---

## IDE Integrations

### Visual Studio Code

#### Installation

```bash
# Run in VS Code integrated terminal
claude
```

#### Features

- **Quick Launch**: `Cmd+Esc` (Mac) or `Ctrl+Esc` (Windows/Linux)
- **File References**: `Cmd+Option+K` (Mac) or `Ctrl+Alt+K` (Windows/Linux)
- **Auto-context**: Current file/selection automatically shared
- **Diff Viewing**: See changes inline
- **Terminal Integration**: Full CLI access

#### Supported VS Code Variants

- Visual Studio Code
- Cursor
- Windsurf
- VSCodium
- Code - OSS

### JetBrains IDEs

#### Supported IDEs

- IntelliJ IDEA
- PyCharm
- WebStorm
- PhpStorm
- GoLand
- Android Studio
- RubyMine
- CLion

#### Installation

**Option 1: Plugin Marketplace**
1. Open IDE Settings/Preferences
2. Navigate to Plugins
3. Search for "Claude Code"
4. Install and restart

**Option 2: Terminal**
```bash
# Run in IDE integrated terminal
claude
```

#### Features

- **Quick Launch**: Configurable shortcut
- **Diff Viewing**: Inline change visualization
- **Error Sharing**: Share diagnostic errors directly
- **Project Context**: Automatic project awareness
- **Refactoring Integration**: Works with IDE refactoring tools

### Terminal Emulators

#### Supported Terminals

- iTerm2 (macOS)
- Terminal.app (macOS)
- Windows Terminal
- Alacritty
- Kitty
- WezTerm
- Hyper

#### Key Bindings Setup

```bash
# Install terminal key bindings
claude
/terminal-setup
```

### Vim Integration

```bash
# Enter vim mode
/vim

# Or configure in .vimrc
:!claude -p "explain this function"
```

---

## Settings & Configuration

### Configuration Hierarchy

Settings are applied in this order (highest priority first):

1. **Enterprise Managed Settings**
   - macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
   - Linux/WSL: `/etc/claude-code/managed-settings.json`
   - Windows: `C:\ProgramData\ClaudeCode\managed-settings.json`

2. **Command Line Arguments**
   ```bash
   claude --model claude-3-5-sonnet --max-turns 10
   ```

3. **Local Project Settings**
   ```
   .claude/settings.local.json  # Personal, not in git
   ```

4. **Shared Project Settings**
   ```
   .claude/settings.json  # Team settings, in git
   ```

5. **User Settings**
   ```
   ~/.claude/settings.json  # Personal defaults
   ```

### Configuration File Structure

```json
{
  "model": "claude-3-5-sonnet-20241022",
  "maxTurns": 10,
  "permissionMode": "ask",
  "allowedTools": ["Read", "Edit", "Bash", "WebSearch"],
  "disallowedTools": ["Write"],
  "env": {
    "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
    "DATABASE_URL": "postgresql://localhost/mydb"
  },
  "hooks": {
    "PostToolUse": {
      "Edit": "prettier --write ${file_path}"
    }
  },
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  },
  "customInstructions": "Always use TypeScript with strict mode",
  "outputStyle": "explanatory",
  "aws": {
    "region": "us-east-1",
    "authRefresh": "aws sso login --profile dev"
  },
  "permissions": {
    "allow": [
      {"tool": "Edit", "path": "src/**/*"},
      {"tool": "Bash", "command": "npm*"}
    ],
    "deny": [
      {"tool": "Edit", "path": "**/production/*"},
      {"tool": "Bash", "command": "rm*"}
    ],
    "ask": [
      {"tool": "Write", "path": "**/*.ts"}
    ]
  }
}
```

### Environment Variables

```bash
# Core settings
export ANTHROPIC_API_KEY="your-key"
export ANTHROPIC_MODEL="claude-3-5-sonnet"
export ANTHROPIC_SMALL_FAST_MODEL="claude-3-5-haiku"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS="4096"
export MAX_THINKING_TOKENS="1024"

# Provider configuration
export CLAUDE_CODE_USE_BEDROCK="1"
export CLAUDE_CODE_USE_VERTEX="1"
export AWS_REGION="us-east-1"
export ANTHROPIC_VERTEX_PROJECT_ID="project-id"

# Network configuration
export HTTPS_PROXY="https://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1"

# Advanced settings
export ANTHROPIC_LOG="debug"
export MCP_TIMEOUT="30000"
export MAX_MCP_OUTPUT_TOKENS="50000"
export DISABLE_PROMPT_CACHING="1"
```

### Managing Settings

```bash
# View current configuration
claude config list

# Set user-level setting
claude config set model claude-3-5-sonnet

# Set project-level setting
claude config set --scope project maxTurns 5

# Set local (private) setting
claude config set --scope local env.DATABASE_URL "postgresql://localhost/dev"

# Add to array setting
claude config add allowedTools "WebFetch"

# Remove from array setting
claude config remove disallowedTools "Grep"
```

### Permission Configuration

```json
{
  "permissions": {
    "allow": [
      {"tool": "Edit", "path": "src/**/*.ts"},
      {"tool": "Bash", "command": "npm test"}
    ],
    "deny": [
      {"tool": "*", "path": "**/.env*"},
      {"tool": "Bash", "command": "sudo*"}
    ],
    "ask": [
      {"tool": "Write"},
      {"tool": "Bash", "command": "git push*"}
    ]
  }
}
```

### Advanced AWS Configuration

```json
{
  "aws": {
    "region": "us-east-1",
    "authRefresh": "aws sso login --profile dev",
    "credentialExport": "aws sts assume-role --role-arn arn:aws:iam::123456789:role/dev"
  }
}
```

---

## Subagents

### Overview

Subagents are specialized AI assistants that handle specific types of tasks with customized system prompts, tools, and separate context windows.

### Key Features

- **Task Specialization**: Fine-tuned for specific domains
- **Context Isolation**: Separate memory prevents pollution
- **Automatic Delegation**: Claude recognizes when to use subagents
- **Tool Control**: Granular permission management

### Creating Subagents

#### Structure

```markdown
---
name: your-subagent-name
description: When this subagent should be invoked
tools: tool1, tool2, tool3  # Optional - inherits all if omitted
---

Your subagent's system prompt goes here. Define the role, 
capabilities, approach, and constraints clearly.
```

#### Storage Locations

- **User-level**: `~/.claude/agents/` (available across projects)
- **Project-level**: `.claude/agents/` (project-specific)

### Example Subagents

#### Code Reviewer

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read, Grep, WebSearch
---

You are a senior code reviewer specializing in:
- Security vulnerabilities
- Performance optimizations
- Code maintainability
- Best practices compliance

For each review:
1. Check for security issues (XSS, SQL injection, etc.)
2. Identify performance bottlenecks
3. Assess code readability and maintainability
4. Verify test coverage
5. Suggest improvements with examples
```

#### Data Analyst

```markdown
---
name: data-analyst
description: SQL and data analysis specialist
tools: Bash, Read, Write
---

You are a data scientist specializing in SQL analysis. 

Key practices:
- Write optimized queries with proper indexing
- Use appropriate aggregations and window functions
- Include explanatory comments
- Format results for readability
- Provide data-driven recommendations

Always ensure queries are efficient and cost-effective.
```

### Managing Subagents

```bash
# Create or modify subagents
/agents

# Explicitly invoke a subagent
> Use the code-reviewer subagent to check my recent changes
```

---

## Output Styles

### Overview

Output styles modify Claude Code's behavior and communication style while maintaining core capabilities.

### Built-in Styles

1. **Default**: Concise, efficient software engineering focus
2. **Explanatory**: Provides educational insights while coding
3. **Learning**: Collaborative mode with `TODO(human)` markers for learning

### Managing Output Styles

```bash
# Access output style menu
/output-style

# Switch directly to a style
/output-style explanatory

# Create custom style
/output-style:new I want a style that explains decisions step-by-step
```

### Custom Output Style Structure

```markdown
---
name: Security Auditor
description: Focuses on security analysis and vulnerability detection
---

You are a security-focused assistant that:
- Prioritizes security considerations in all code
- Identifies potential vulnerabilities
- Suggests secure alternatives
- Explains security implications clearly
- References OWASP guidelines when relevant
```

### Storage

- **User-level**: `~/.claude/output-styles/`
- **Project settings**: `.claude/settings.local.json`

---

## Hooks

### Overview

Hooks are user-defined shell commands that execute at specific points in Claude Code's lifecycle, providing deterministic control over behavior.

### Use Cases

- **Notifications**: Custom alerts when Claude needs input
- **Automatic Formatting**: Run formatters after file edits
- **Logging**: Track commands for compliance
- **Feedback**: Enforce coding standards
- **Permissions**: Block sensitive operations

### Hook Events

| Event | Description | Can Block |
|-------|-------------|-----------|
| **PreToolUse** | Before tool execution | Yes |
| **PostToolUse** | After tool completion | No |
| **UserPromptSubmit** | When user submits prompt | No |
| **Notification** | When notifications sent | No |
| **Stop** | When Claude finishes | No |
| **SubagentStop** | When subagent completes | No |
| **PreCompact** | Before context compaction | No |
| **SessionStart** | When session begins | No |

### Hook Configuration

#### Example: Auto-formatting Hook

```json
{
  "hooks": {
    "PostToolUse": {
      "Edit": "prettier --write ${file_path} 2>/dev/null || true"
    }
  }
}
```

#### Example: Security Hook

```json
{
  "hooks": {
    "PreToolUse": {
      "Edit": "if [[ '${file_path}' == *production* ]]; then echo 'BLOCKED: Cannot edit production files'; exit 1; fi"
    }
  }
}
```

### Security Considerations

⚠️ **Important**: Hooks run with your environment's credentials
- Review hook code before implementation
- Avoid untrusted hook sources
- Be cautious with sensitive data access
- Use exit codes to block operations

---

## GitHub Actions Integration

### Overview

Claude Code GitHub Actions enables AI-powered automation in GitHub workflows through simple `@claude` mentions in PRs and issues.

### Features

- **Instant PR Creation**: Turn descriptions into complete PRs
- **Automated Implementation**: Convert issues to working code
- **Standards Compliance**: Follows `CLAUDE.md` guidelines
- **Secure Execution**: Runs on GitHub's infrastructure

### Quick Setup

#### Method 1: CLI Setup

```bash
# In Claude Code
/install-github-app

# Follow prompts to create workflow
# Add ANTHROPIC_API_KEY to repository secrets
# Merge the generated PR
```

#### Method 2: Manual Setup

1. Install [Claude GitHub App](https://github.com/apps/claude)
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Create `.github/workflows/claude.yml`:

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude:
    if: contains(github.event.comment.body, '@claude')
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Advanced Configuration

#### Cloud Provider Integration

**AWS Bedrock:**
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT:role/GitHubActionsRole
    aws-region: us-east-1
    
- uses: anthropics/claude-code-action@v1
  with:
    provider: bedrock
    aws_region: us-east-1
```

**Google Vertex AI:**
```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: projects/PROJECT/locations/global/workloadIdentityPools/POOL/providers/PROVIDER
    service_account: SERVICE_ACCOUNT@PROJECT.iam.gserviceaccount.com
    
- uses: anthropics/claude-code-action@v1
  with:
    provider: vertex
    vertex_project_id: your-project-id
    vertex_region: us-central1
```

### CLAUDE.md Configuration

Create project guidelines in `CLAUDE.md`:

```markdown
# Project Guidelines for Claude

## Code Style
- Use TypeScript with strict mode
- Follow ESLint configuration
- Write comprehensive tests

## Architecture
- Follow domain-driven design
- Use dependency injection
- Implement repository pattern

## Review Criteria
- Check for security vulnerabilities
- Ensure 80% test coverage
- Verify performance implications
```

---

## Model Context Protocol (MCP)

### Overview

MCP is an open standard enabling Claude Code to connect with external tools, databases, and APIs.

### Capabilities

- **Issue Tracking**: "Implement the feature from JIRA-123"
- **Monitoring**: "Check Sentry for errors in the payment service"
- **Databases**: "Query user analytics from PostgreSQL"
- **Design Tools**: "Update components based on the Figma designs"
- **Communication**: "Draft emails for the beta testers"

### Installation Methods

#### 1. Local Stdio Server

```bash
# Filesystem access
claude mcp add filesystem npx -y @modelcontextprotocol/server-filesystem /path/to/directory

# PostgreSQL
claude mcp add postgres npx -y @modelcontextprotocol/server-postgres postgresql://user:pass@localhost:5432/db

# With environment variables
claude mcp add github --env GITHUB_TOKEN=your_token -- npx -y @modelcontextprotocol/server-github
```

#### 2. Remote SSE Server

```bash
claude mcp add --transport sse linear https://mcp.linear.app/sse
claude mcp add --transport sse notion https://mcp.notion.com/sse
```

#### 3. Remote HTTP Server

```bash
claude mcp add --transport http api https://api.example.com/mcp
```

### Configuration Scopes

- **Local** (default): Project-specific, private
- **Project**: Team-shared via `.mcp.json`
- **User**: Personal, cross-project

```bash
# Add to project scope
claude mcp add --scope project github npx -y @modelcontextprotocol/server-github

# Add to user scope
claude mcp add --scope user memory npx -y @modelcontextprotocol/server-memory
```

### Popular MCP Servers

| Server | Purpose | Installation |
|--------|---------|--------------|
| **filesystem** | File access | `claude mcp add filesystem npx -y @modelcontextprotocol/server-filesystem /path` |
| **git** | Git operations | `claude mcp add git npx -y @modelcontextprotocol/server-git --repository /path` |
| **postgres** | Database queries | `claude mcp add postgres --env DATABASE_URL=url -- npx -y @modelcontextprotocol/server-postgres` |
| **github** | GitHub API | `claude mcp add github --env GITHUB_TOKEN=token -- npx -y @modelcontextprotocol/server-github` |
| **slack** | Slack integration | `claude mcp add slack --env SLACK_TOKEN=token -- npx -y @modelcontextprotocol/server-slack` |

### Authentication

```bash
# OAuth 2.0 authentication
/mcp auth linear
/mcp auth notion
/mcp auth github
```

### Resource References

Use @ mentions to reference MCP resources:

```bash
@github:issues/123
@linear:ENG-456
@filesystem:/path/to/file.txt
```

### Security Considerations

⚠️ **Important**:
- Only use trusted MCP servers
- Review server permissions
- Be cautious with untrusted content sources
- Use environment variables for credentials
- Avoid prompt injection risks

---

## SDK Development

### Overview

The Claude Code SDK enables building custom AI agents with Claude's capabilities in TypeScript, Python, and headless modes.

### SDK Options

1. **Headless Mode**: CLI automation and scripts
2. **TypeScript SDK**: Node.js and web applications
3. **Python SDK**: Python applications and data science

### Core Concepts

#### Authentication

```bash
# Anthropic API
export ANTHROPIC_API_KEY=your-key

# AWS Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# Google Vertex AI
export CLAUDE_CODE_USE_VERTEX=1
export ANTHROPIC_VERTEX_PROJECT_ID=your-project
```

#### System Prompts

Define agent behavior and expertise:

```python
system_prompt = """
You are a senior security auditor specializing in:
- Vulnerability detection
- Compliance verification
- Security best practices
- Threat modeling

Provide actionable recommendations with severity ratings.
"""
```

#### Tool Permissions

Control agent capabilities:

```python
options = ClaudeCodeOptions(
    allowed_tools=["Read", "Grep", "WebSearch"],
    disallowed_tools=["Bash", "Edit"],  # Read-only mode
    permission_mode="prompt"  # Ask before tool use
)
```

### Headless Mode

#### Basic Usage

```bash
claude -p "Analyze security vulnerabilities" \
  --allowedTools "Read,Grep" \
  --permission-mode acceptEdits \
  --cwd /path/to/project
```

#### Multi-turn Conversations

```bash
# Continue most recent
claude --continue "Now fix the critical issues"

# Resume specific session
claude --resume 550e8400-e29b-41d4 "Update the tests"
```

#### Automation Examples

```bash
# SRE Incident Response
investigate_incident() {
    claude -p "Incident: $1 (Severity: $2)" \
      --append-system-prompt "You are an SRE expert. Diagnose and provide action items." \
      --output-format json \
      --allowedTools "Bash,Read,WebSearch,mcp__datadog"
}

# Security Audit
audit_security() {
    claude -p "Perform security audit" \
      --system-prompt "You are a security expert. Find vulnerabilities and compliance issues." \
      --cwd "$1" \
      --allowedTools "Read,Grep"
}
```

### Python SDK

#### Installation

```bash
pip install claude-code-sdk
npm install -g @anthropic-ai/claude-code  # Required dependency
```

#### Basic Usage

```python
import asyncio
from claude_code_sdk import ClaudeSDKClient, ClaudeCodeOptions

async def main():
    async with ClaudeSDKClient(
        options=ClaudeCodeOptions(
            system_prompt="You are a performance engineer",
            max_turns=5,
            allowed_tools=["Bash", "Read", "WebSearch"]
        )
    ) as client:
        await client.query("Analyze system performance")
        
        async for message in client.receive_response():
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        print(block.text, end='', flush=True)

asyncio.run(main())
```

#### Image Analysis

```python
async with ClaudeSDKClient() as client:
    await client.query_with_images(
        "What issues do you see in this screenshot?",
        image_paths=["screenshot.png"]
    )
```

### TypeScript SDK

#### Installation

```bash
npm install @anthropic-ai/claude-code
```

#### Basic Usage

```typescript
import { query } from "@anthropic-ai/claude-code";

for await (const message of query({
  prompt: "Analyze the codebase architecture",
  options: {
    maxTurns: 5,
    systemPrompt: "You are a software architect",
    allowedTools: ["Read", "Grep", "WebSearch"]
  }
})) {
  if (message.type === "result") {
    console.log(message.result);
  }
}
```

#### Multi-turn Conversations

```typescript
// Continue conversation
for await (const message of query({
  prompt: "Now optimize the critical paths",
  options: { continue: true }
})) {
  if (message.type === "result") console.log(message.result);
}
```

#### Custom Tools

```typescript
const customTool: ToolDefinition = {
  name: "analyzeMetrics",
  description: "Analyze performance metrics",
  inputSchema: {
    type: "object",
    properties: {
      timeRange: { type: "string" },
      service: { type: "string" }
    },
    required: ["timeRange", "service"]
  }
};

const options = {
  customTools: [customTool],
  customToolHandler: async (toolName: string, args: any) => {
    if (toolName === "analyzeMetrics") {
      return { analysis: "Performance data", recommendations: [] };
    }
  }
};
```

---

## Enterprise Deployment

### Provider Comparison

| Feature | Anthropic | Amazon Bedrock | Google Vertex AI |
|---------|-----------|----------------|-----------------|
| **Regions** | [Supported countries](https://www.anthropic.com/supported-countries) | Multiple AWS regions | Multiple GCP regions |
| **Prompt caching** | Enabled by default | Enabled by default | Enabled by default |
| **Authentication** | API key | AWS IAM | GCP OAuth/Service Account |
| **Cost tracking** | Dashboard | AWS Cost Explorer | GCP Billing |
| **Compliance** | SOC 2, HIPAA | AWS compliance | GCP compliance |

### Amazon Bedrock Setup

#### 1. Enable Model Access

1. Navigate to [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/)
2. Go to **Model access**
3. Request access to Claude models
4. Wait for approval (usually instant)

#### 2. Configure Credentials

```bash
# Option A: AWS CLI
aws configure

# Option B: Environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_SESSION_TOKEN=your-token

# Option C: SSO
aws sso login --profile=your-profile
export AWS_PROFILE=your-profile

# Option D: Bedrock API keys
export AWS_BEARER_TOKEN_BEDROCK=your-api-key
```

#### 3. Enable Bedrock

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024
```

#### 4. IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:ListInferenceProfiles"
    ],
    "Resource": [
      "arn:aws:bedrock:*:*:inference-profile/*",
      "arn:aws:bedrock:*:*:application-inference-profile/*"
    ]
  }]
}
```

### Google Vertex AI Setup

```bash
# Enable Vertex
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=your-project-id

# Configure authentication
gcloud auth application-default login
```

### Corporate Infrastructure

#### Corporate Proxy

```bash
# Basic proxy configuration
export HTTPS_PROXY='https://proxy.example.com:8080'
export HTTP_PROXY='http://proxy.example.com:8080'

# With authentication
export HTTPS_PROXY='https://user:pass@proxy.example.com:8080'

# Bypass for local
export NO_PROXY='localhost,127.0.0.1'
```

#### LLM Gateway

```bash
# Configure gateway endpoint
export ANTHROPIC_BASE_URL='https://llm-gateway.company.com/v1'

# Skip provider auth if gateway handles it
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
```

### Best Practices for Organizations

1. **Documentation Strategy**
   - Create organization-wide `CLAUDE.md`
   - Add repository-level guidelines
   - Document architectural decisions

2. **Deployment Automation**
   - Create one-click installation scripts
   - Configure default settings
   - Automate credential management

3. **Security Policies**
   - Configure managed permissions
   - Implement audit logging
   - Set up compliance monitoring

4. **Training & Adoption**
   - Start with codebase Q&A
   - Progress to small bug fixes
   - Gradually expand use cases

5. **Integration Strategy**
   - Deploy MCP servers centrally
   - Share `.mcp.json` configurations
   - Connect to existing tools

---

## Troubleshooting

### Windows/WSL Issues

#### Node.js Detection

```bash
# Fix OS detection
npm config set os linux
npm install -g @anthropic-ai/claude-code --force --no-os-check

# Verify paths
which node
which npm
```

#### NVM Configuration

```bash
# Add to ~/.bashrc or ~/.zshrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### Authentication Issues

```bash
# Reset authentication
rm -rf ~/.config/claude-code/auth.json
claude
/login
```

### Performance Optimization

1. **Reduce Context Size**
   ```bash
   /compact
   ```

2. **Manage Large Projects**
   - Add build directories to `.gitignore`
   - Use `.claudeignore` for exclusions
   - Close and restart between major tasks

### Search Tools

#### Installing ripgrep

```bash
# macOS
brew install ripgrep

# Windows
winget install BurntSushi.ripgrep.MSVC

# Ubuntu/Debian
sudo apt install ripgrep

# Fedora
dnf install ripgrep
```

### Common Error Solutions

| Error | Solution |
|-------|----------|
| "Command not found" | Verify PATH includes installation directory |
| "Authentication failed" | Run `/logout` then `/login` |
| "Rate limit exceeded" | Wait or upgrade API plan |
| "Context too large" | Use `/compact` or restart session |
| "Tool permission denied" | Check `allowedTools` configuration |

### Debugging

```bash
# Enable debug logging
export ANTHROPIC_LOG=debug

# Check configuration
claude /status

# View MCP logs (macOS)
tail -f ~/Library/Logs/Claude/mcp*.log
```

---

## Best Practices

### 1. Project Configuration

#### CLAUDE.md Files

Create clear guidelines for Claude:

```markdown
# Project Guidelines

## Architecture
- Follow MVC pattern
- Use dependency injection
- Implement repository pattern

## Code Style
- TypeScript with strict mode
- 100 character line limit
- Comprehensive JSDoc comments

## Testing
- Minimum 80% coverage
- Unit tests for all public methods
- Integration tests for API endpoints

## Security
- Input validation on all endpoints
- Use parameterized queries
- No secrets in code
```

#### .claudeignore

Exclude unnecessary files:

```
node_modules/
dist/
build/
*.log
.env*
coverage/
```

### 2. Session Management

- **Start Fresh**: Begin new sessions for unrelated tasks
- **Use Compact**: Run `/compact` when context grows large
- **Clear Todos**: Keep todo list current and relevant
- **Resume Wisely**: Use `--continue` for related work

### 3. Effective Prompting

#### Be Specific

```bash
# Good
> Add input validation to the user registration endpoint that checks email format, password strength, and username uniqueness

# Less effective
> Make the registration better
```

#### Provide Context

```bash
# Good
> The payment service is timing out. Check the database queries in PaymentService.ts and optimize them

# Less effective
> Fix the timeout issue
```

### 4. Code Quality

#### Test-Driven Development

```bash
> Write tests for the new authentication middleware before implementing it
```

#### Incremental Changes

```bash
> Let's refactor the user service step by step. First, extract the validation logic
```

### 5. Security Considerations

- **Review Changes**: Always review Claude's modifications
- **Sensitive Data**: Never share credentials or secrets
- **Production Safety**: Use hooks to prevent production changes
- **Audit Trail**: Enable logging for compliance

### 6. Team Collaboration

#### Shared Configuration

1. Create team `.claude/` directory
2. Define shared subagents
3. Establish coding standards in `CLAUDE.md`
4. Configure MCP servers in `.mcp.json`

#### Knowledge Sharing

- Document successful patterns
- Share useful subagents
- Create team-specific output styles
- Maintain prompt templates

### 7. Performance Optimization

- **Parallel Operations**: Use multiple tools simultaneously
- **Targeted Searches**: Use specific patterns with Grep
- **Efficient Agents**: Create specialized subagents
- **Resource Management**: Monitor token usage

### 8. Workflow Integration

#### CI/CD Pipeline

```yaml
# Use Claude in CI/CD
- name: Claude Code Review
  run: |
    claude -p "Review the changes in this PR for security issues" \
      --allowedTools "Read,Grep" \
      --output-format json
```

#### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit
claude -p "Check for common issues in staged files" \
  --allowedTools "Read" \
  --permission-mode readonly
```

### 9. Advanced Techniques

#### Chaining Commands

```bash
# Unix pipeline integration
git diff | claude -p "Explain these changes"
tail -f app.log | claude -p "Alert me if you see errors"
```

#### Custom Automation

```bash
# Create custom Claude commands
alias claude-review='claude -p "Review this code for best practices"'
alias claude-test='claude -p "Write comprehensive tests for this file"'
alias claude-doc='claude -p "Add documentation to this code"'
```

### 10. Continuous Improvement

- **Iterate on Prompts**: Refine prompts based on results
- **Update Guidelines**: Evolve `CLAUDE.md` with lessons learned
- **Monitor Usage**: Track successful patterns
- **Share Feedback**: Report issues and feature requests

---

## Conclusion

Claude Code represents a paradigm shift in software development, bringing AI assistance directly into your terminal workflow. By following the practices and patterns outlined in this guide, you can maximize productivity while maintaining code quality and security.

### Key Takeaways

1. **Start Simple**: Begin with codebase exploration and small tasks
2. **Configure Thoughtfully**: Set up proper guidelines and constraints
3. **Leverage Specialization**: Use subagents for domain-specific tasks
4. **Integrate Deeply**: Connect with your existing tools via MCP
5. **Maintain Control**: Use hooks and permissions for governance
6. **Think Long-term**: Build sustainable practices and documentation

### Resources

- **Documentation**: https://docs.anthropic.com/claude-code
- **GitHub**: https://github.com/anthropics/claude-code
- **Support**: https://support.anthropic.com
- **Community**: https://community.anthropic.com

### Feedback

Report issues and feature requests: https://github.com/anthropics/claude-code/issues

---

*This comprehensive guide is based on official Claude Code documentation and represents best practices as of January 2025. For the most current information, always refer to the official documentation.*
