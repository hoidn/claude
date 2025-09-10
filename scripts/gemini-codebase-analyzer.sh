#!/bin/bash
# gemini-codebase-analyzer.sh
# 
# A robust script for analyzing codebases with Gemini using repomix for context aggregation.
# Follows best practices from Claude Code command patterns.
#
# Usage: ./gemini-codebase-analyzer.sh "Your task or question for Gemini"
# Example: ./gemini-codebase-analyzer.sh "Analyze the authentication workflow and identify potential security issues"

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Default configuration (can be overridden by environment variables)
REPOMIX_INCLUDE="${REPOMIX_INCLUDE:-**/*.{js,py,md,sh,json,c,h,yml,yaml,toml,rs,go,cpp,hpp,ts,tsx,jsx}}"
REPOMIX_IGNORE="${REPOMIX_IGNORE:-build/**,node_modules/**,dist/**,*.lock,.claude/**,venv/**,__pycache__/**,*.pyc,tmp/**,temp/**,trash/**,.git/**}"
REPOMIX_TOP_FILES="${REPOMIX_TOP_FILES:-20}"
GEMINI_MODEL="${GEMINI_MODEL:-}"  # Empty means use default

# ============================================================================
# USAGE & HELP
# ============================================================================

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] "Your task or question for Gemini"

Analyzes a codebase using Gemini with repomix for context aggregation.

OPTIONS:
    -h, --help              Show this help message
    -o, --output DIR        Output directory for artifacts (default: ./tmp/gemini_run_\$TIMESTAMP)
    -i, --include PATTERN   File patterns to include (default: common code files)
    -x, --exclude PATTERN   File patterns to exclude (default: build artifacts, dependencies)
    -t, --top-files NUM     Number of top files to include (default: 20)
    -k, --keep              Keep temporary files after completion
    -v, --verbose           Verbose output for debugging
    --dry-run               Show what would be executed without running

EXAMPLES:
    # Basic usage
    $SCRIPT_NAME "Explain the data flow in this application"
    
    # Include only Python files
    $SCRIPT_NAME -i "**/*.py" "Find all uses of global state"
    
    # Custom output directory
    $SCRIPT_NAME -o ./analysis "Review the error handling patterns"
    
    # Verbose mode for debugging
    $SCRIPT_NAME -v "Identify performance bottlenecks"

ENVIRONMENT VARIABLES:
    REPOMIX_INCLUDE    Default file include patterns
    REPOMIX_IGNORE     Default file exclude patterns
    REPOMIX_TOP_FILES  Default number of top files
    GEMINI_MODEL       Specific Gemini model to use

EOF
    exit 0
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

# Initialize variables
USER_TASK=""
OUTPUT_DIR=""
KEEP_TEMP=false
VERBOSE=false
DRY_RUN=false
CUSTOM_INCLUDE=""
CUSTOM_EXCLUDE=""
CUSTOM_TOP_FILES=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -i|--include)
            CUSTOM_INCLUDE="$2"
            shift 2
            ;;
        -x|--exclude)
            CUSTOM_EXCLUDE="$2"
            shift 2
            ;;
        -t|--top-files)
            CUSTOM_TOP_FILES="$2"
            shift 2
            ;;
        -k|--keep)
            KEEP_TEMP=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            echo "❌ Unknown option: $1" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
        *)
            # Assume this is the user task
            if [ -z "$USER_TASK" ]; then
                USER_TASK="$1"
            else
                echo "❌ Multiple tasks provided. Please quote your entire task." >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$USER_TASK" ]; then
    echo "❌ ERROR: No task provided." >&2
    echo "Usage: $SCRIPT_NAME \"Your task or question\"" >&2
    exit 1
fi

# Apply custom settings if provided
[ -n "$CUSTOM_INCLUDE" ] && REPOMIX_INCLUDE="$CUSTOM_INCLUDE"
[ -n "$CUSTOM_EXCLUDE" ] && REPOMIX_IGNORE="$CUSTOM_EXCLUDE"
[ -n "$CUSTOM_TOP_FILES" ] && REPOMIX_TOP_FILES="$CUSTOM_TOP_FILES"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date +'%H:%M:%S')] $*" >&2
    fi
}

info() {
    echo "ℹ️  $*"
}

success() {
    echo "✅ $*"
}

error() {
    echo "❌ ERROR: $*" >&2
}

# Cleanup function
cleanup() {
    if [ "$KEEP_TEMP" = false ] && [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        log "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

check_prerequisites() {
    local missing_tools=()
    
    # Check for required tools
    if ! command -v npx &> /dev/null; then
        missing_tools+=("npx (Node.js)")
    fi
    
    if ! command -v gemini &> /dev/null; then
        missing_tools+=("gemini (Gemini CLI)")
    fi
    
    # Check for timeout command (gtimeout on macOS, timeout on Linux)
    if command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    elif command -v timeout &> /dev/null; then
        TIMEOUT_CMD="timeout"
    else
        # No timeout command available, we'll run without timeout
        TIMEOUT_CMD=""
        log "Warning: No timeout command found (install coreutils on macOS)"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and try again." >&2
        exit 1
    fi
    
    log "All prerequisites satisfied"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Set up signal handlers for cleanup
    trap cleanup EXIT INT TERM
    
    # Check prerequisites
    check_prerequisites
    
    # Create temporary directory
    if [ -z "$OUTPUT_DIR" ]; then
        TEMP_DIR="./tmp/gemini_run_${TIMESTAMP}"
    else
        TEMP_DIR="$OUTPUT_DIR"
    fi
    
    mkdir -p "$TEMP_DIR"
    log "Using temporary directory: $TEMP_DIR"
    
    # Define file paths
    REPOMIX_OUTPUT="$TEMP_DIR/repomix-output.xml"
    PROMPT_FILE="$TEMP_DIR/gemini-prompt.md"
    RESPONSE_FILE="$TEMP_DIR/gemini-response.txt"
    
    # ========================================================================
    # STEP 1: Run repomix to aggregate codebase context
    # ========================================================================
    
    info "Step 1: Aggregating codebase context with repomix..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: Would execute:"
        echo "npx repomix@latest . \\"
        echo "  --top-files-len $REPOMIX_TOP_FILES \\"
        echo "  --include \"$REPOMIX_INCLUDE\" \\"
        echo "  --ignore \"$REPOMIX_IGNORE\" \\"
        echo "  -o \"$REPOMIX_OUTPUT\""
    else
        log "Running: npx repomix@latest with include=$REPOMIX_INCLUDE"
        
        npx repomix@latest . \
            --top-files-len "$REPOMIX_TOP_FILES" \
            --include "$REPOMIX_INCLUDE" \
            --ignore "$REPOMIX_IGNORE" \
            -o "$REPOMIX_OUTPUT" 2>&1 | while read -r line; do
                log "repomix: $line"
            done
        
        if [ ! -s "$REPOMIX_OUTPUT" ]; then
            error "Repomix failed to generate the codebase context"
            exit 1
        fi
        
        # Get file size for reporting
        CONTEXT_SIZE=$(du -h "$REPOMIX_OUTPUT" | cut -f1)
        success "Codebase context aggregated: $CONTEXT_SIZE in $REPOMIX_OUTPUT"
    fi
    
    # ========================================================================
    # STEP 2: Build the structured prompt file
    # ========================================================================
    
    info "Step 2: Building structured prompt file..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: Would create prompt file at $PROMPT_FILE"
        echo "Task: $USER_TASK"
    else
        # Create the initial prompt structure using heredoc
        # Using 'PROMPT_TEMPLATE' as delimiter to avoid conflicts
        cat > "$PROMPT_FILE" << 'PROMPT_TEMPLATE'
# TODO need better handholding on starting with CLAUDE.md and other proj docs, etc.
# See geminictx.py/sh
<task>
You are an expert software engineer and architect tasked with analyzing a codebase to answer a specific question or complete a specific task.

## Your Task

PROMPT_TEMPLATE
        
        # Append the user's task (safely, without interpretation)
        echo "$USER_TASK" >> "$PROMPT_FILE"
        
        # Continue building the prompt structure
        cat >> "$PROMPT_FILE" << 'PROMPT_TEMPLATE'

## Instructions

1. **Carefully review** the provided codebase context below
2. **Analyze** the code structure, patterns, dependencies, and implementation details
3. **Provide a comprehensive response** that directly addresses the task above
4. **Be specific** with file references, function names, and code examples when relevant
5. **Consider** architectural implications, best practices, and potential improvements

## Response Guidelines

- Start with a brief executive summary (2-3 sentences)
- Organize your analysis into clear sections
- Use code blocks with language syntax highlighting when showing examples
- Reference specific files using their full paths (e.g., `src/auth/login.py`)
- Highlight any potential issues, risks, or areas of concern
- Conclude with actionable recommendations if applicable

## About the Codebase Context

The codebase context below is provided in a structured XML format generated by repomix. It contains:
- File contents with their paths
- Repository structure information
- Top files by size/importance

Pay special attention to:
- Import statements and dependencies
- Function and class definitions
- Configuration files and environment settings
- Documentation and comments
- Test files that demonstrate intended behavior

</task>

<codebase_context>
PROMPT_TEMPLATE
        
        # Append the repomix output
        log "Appending repomix output to prompt file..."
        cat "$REPOMIX_OUTPUT" >> "$PROMPT_FILE"
        
        # Close the codebase context tag
        echo "</codebase_context>" >> "$PROMPT_FILE"
        
        success "Prompt file created: $PROMPT_FILE"
        
        # Report prompt file size
        PROMPT_SIZE=$(du -h "$PROMPT_FILE" | cut -f1)
        log "Prompt file size: $PROMPT_SIZE"
    fi
    
    # ========================================================================
    # STEP 3: Execute Gemini with the prompt file
    # ========================================================================
    
    info "Step 3: Executing Gemini analysis..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: Would execute:"
        echo "gemini -p \"carefully complete the <task> in @$PROMPT_FILE\" > \"$RESPONSE_FILE\""
    else
        log "Calling Gemini (this may take a minute or more)..."
        
        # Execute Gemini with timeout protection (10 minutes) if available
        local gemini_success=false
        if [ -n "$TIMEOUT_CMD" ]; then
            if $TIMEOUT_CMD 600 gemini -p "carefully complete the <task> in @$PROMPT_FILE" > "$RESPONSE_FILE" 2>&1; then
                gemini_success=true
            fi
        else
            # Run without timeout
            if gemini -p "carefully complete the <task> in @$PROMPT_FILE" > "$RESPONSE_FILE" 2>&1; then
                gemini_success=true
            fi
        fi
        
        if [ "$gemini_success" = true ]; then
            if [ ! -s "$RESPONSE_FILE" ]; then
                error "Gemini command succeeded but produced no output"
                exit 1
            fi
            
            success "Gemini analysis complete"
            
            # Display the response
            echo ""
            echo "════════════════════════════════════════════════════════════════════════"
            echo "                           GEMINI ANALYSIS RESULT                       "
            echo "════════════════════════════════════════════════════════════════════════"
            echo ""
            cat "$RESPONSE_FILE"
            echo ""
            echo "════════════════════════════════════════════════════════════════════════"
            
            # Save locations
            echo ""
            info "Analysis saved to: $RESPONSE_FILE"
            info "Prompt file: $PROMPT_FILE"
            info "Codebase context: $REPOMIX_OUTPUT"
            
            if [ "$KEEP_TEMP" = true ]; then
                info "Temporary files retained in: $TEMP_DIR"
            else
                info "Temporary files will be cleaned up (use -k to keep)"
            fi
        else
            error "Gemini command failed or timed out"
            echo "Check $RESPONSE_FILE for error details" >&2
            exit 1
        fi
    fi
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"
