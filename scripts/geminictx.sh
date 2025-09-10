#!/bin/bash
# geminictx.sh
#
# Two-pass AI workflow for comprehensive codebase analysis
# Pass 1: Gemini identifies relevant files from aggregated context
# Pass 2: Process identified files (display, extract content, or create synthesis prompt)
#
# Usage: ./geminictx.sh "Your query about the codebase"
# Example: ./geminictx.sh "How does the authentication system work?"

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
VERSION="1.0.0"

# Default configuration (can be overridden by environment variables)
REPOMIX_INCLUDE="${REPOMIX_INCLUDE:-**/*.{js,py,md,sh,json,c,h,yml,yaml,toml,rs,go,cpp,hpp,ts,tsx,jsx}}"
REPOMIX_IGNORE="${REPOMIX_IGNORE:-build/**,node_modules/**,dist/**,*.lock,.claude/**,venv/**,__pycache__/**,*.pyc,tmp/**,temp/**,trash/**,.git/**,PtychoNN/**,torch/**}"
REPOMIX_TOP_FILES="${REPOMIX_TOP_FILES:-20}"
GEMINI_MODEL="${GEMINI_MODEL:-}"  # Empty means use default
MAX_FILES_TO_PROCESS="${MAX_FILES_TO_PROCESS:-25}"
CLEAN_OLD_DAYS="${CLEAN_OLD_DAYS:-7}"  # Clean temp dirs older than this

# Pass 2 modes
PASS2_MODE="display"  # display, content, prompt

# ============================================================================
# USAGE & HELP
# ============================================================================

usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION - Two-pass AI workflow for codebase analysis

Usage: $SCRIPT_NAME [OPTIONS] "Your query about the codebase"

DESCRIPTION:
    Implements a sophisticated two-pass analysis workflow:
    Pass 1: Gemini analyzes the entire codebase context to identify relevant files
    Pass 2: Process the identified files based on selected mode

OPTIONS:
    -h, --help              Show this help message
    -o, --output DIR        Output directory for artifacts (default: ./tmp/geminictx_run_\$TIMESTAMP)
    -i, --include PATTERN   File patterns to include (default: common code files)
    -x, --exclude PATTERN   File patterns to exclude (default: build artifacts, dependencies)
    -t, --top-files NUM     Number of top files to include (default: 20)
    -m, --max-files NUM     Maximum files to process in Pass 2 (default: 25)
    -p, --pass2 MODE        Pass 2 mode: display, content, prompt (default: display)
                           - display: Show list of identified files with relevance
                           - content: Output full content of identified files
                           - prompt: Create a synthesis prompt file for Claude
    -k, --keep              Keep temporary files after completion
    -c, --clean-old         Clean temp directories older than $CLEAN_OLD_DAYS days
    -v, --verbose           Verbose output for debugging
    --dry-run               Show what would be executed without running
    --no-emoji              Disable emoji in output

EXAMPLES:
    # Basic usage - identify relevant files
    $SCRIPT_NAME "How does authentication work?"
    
    # Extract content of identified files
    $SCRIPT_NAME -p content "Explain the data pipeline"
    
    # Create a synthesis prompt for Claude
    $SCRIPT_NAME -p prompt -o ./analysis "Find security vulnerabilities"
    
    # Include only Python files with verbose output
    $SCRIPT_NAME -i "**/*.py" -v "Analyze the class hierarchy"
    
    # Clean old temp files and run analysis
    $SCRIPT_NAME -c "Review error handling patterns"

ENVIRONMENT VARIABLES:
    REPOMIX_INCLUDE       Default file include patterns
    REPOMIX_IGNORE        Default file exclude patterns
    REPOMIX_TOP_FILES     Default number of top files
    GEMINI_MODEL          Specific Gemini model to use
    MAX_FILES_TO_PROCESS  Maximum files for Pass 2
    NO_COLOR              Disable colored output

PASS 2 MODES:
    display  - Shows a formatted list of identified files with scores and relevance
    content  - Outputs the full content of identified files (useful for piping)
    prompt   - Creates a prompt file with all file contents for manual Claude usage

OUTPUT FILES:
    \$OUTPUT_DIR/repomix-output.xml      - Aggregated codebase context
    \$OUTPUT_DIR/gemini-pass1-prompt.md  - Pass 1 prompt sent to Gemini
    \$OUTPUT_DIR/gemini-pass1-response.txt - Gemini's response
    \$OUTPUT_DIR/identified-files.txt     - List of identified files
    \$OUTPUT_DIR/synthesis-prompt.md      - (prompt mode) Ready-to-use Claude prompt

EOF
    exit 0
}

# ============================================================================
# COLOR AND EMOJI CONFIGURATION
# ============================================================================

# Check if output is to a terminal and color is not disabled
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    COLOR_RESET='\033[0m'
    COLOR_RED='\033[0;31m'
    COLOR_GREEN='\033[0;32m'
    COLOR_YELLOW='\033[0;33m'
    COLOR_BLUE='\033[0;34m'
    COLOR_MAGENTA='\033[0;35m'
    COLOR_CYAN='\033[0;36m'
    COLOR_BOLD='\033[1m'
else
    COLOR_RESET=''
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_BLUE=''
    COLOR_MAGENTA=''
    COLOR_CYAN=''
    COLOR_BOLD=''
fi

USE_EMOJI=true

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

# Initialize variables
USER_QUERY=""
OUTPUT_DIR=""
KEEP_TEMP=false
VERBOSE=false
DRY_RUN=false
CLEAN_OLD=false
CUSTOM_INCLUDE=""
CUSTOM_EXCLUDE=""
CUSTOM_TOP_FILES=""
CUSTOM_MAX_FILES=""

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
        -m|--max-files)
            CUSTOM_MAX_FILES="$2"
            shift 2
            ;;
        -p|--pass2)
            PASS2_MODE="$2"
            if [[ ! "$PASS2_MODE" =~ ^(display|content|prompt)$ ]]; then
                echo "❌ Invalid pass2 mode: $PASS2_MODE" >&2
                echo "Valid modes: display, content, prompt" >&2
                exit 1
            fi
            shift 2
            ;;
        -k|--keep)
            KEEP_TEMP=true
            shift
            ;;
        -c|--clean-old)
            CLEAN_OLD=true
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
        --no-emoji)
            USE_EMOJI=false
            shift
            ;;
        -*)
            echo "❌ Unknown option: $1" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
        *)
            # Assume this is the user query
            if [ -z "$USER_QUERY" ]; then
                USER_QUERY="$1"
            else
                echo "❌ Multiple queries provided. Please quote your entire query." >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$USER_QUERY" ]; then
    echo "❌ ERROR: No query provided." >&2
    echo "Usage: $SCRIPT_NAME \"Your query about the codebase\"" >&2
    exit 1
fi

# Apply custom settings if provided
[ -n "$CUSTOM_INCLUDE" ] && REPOMIX_INCLUDE="$CUSTOM_INCLUDE"
[ -n "$CUSTOM_EXCLUDE" ] && REPOMIX_IGNORE="$CUSTOM_EXCLUDE"
[ -n "$CUSTOM_TOP_FILES" ] && REPOMIX_TOP_FILES="$CUSTOM_TOP_FILES"
[ -n "$CUSTOM_MAX_FILES" ] && MAX_FILES_TO_PROCESS="$CUSTOM_MAX_FILES"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${COLOR_CYAN}[$(date +'%H:%M:%S')]${COLOR_RESET} $*" >&2
    fi
}

info() {
    local emoji=""
    [ "$USE_EMOJI" = true ] && emoji="ℹ️  "
    echo -e "${COLOR_BLUE}${emoji}$*${COLOR_RESET}"
}

success() {
    local emoji=""
    [ "$USE_EMOJI" = true ] && emoji="✅ "
    echo -e "${COLOR_GREEN}${emoji}$*${COLOR_RESET}"
}

warning() {
    local emoji=""
    [ "$USE_EMOJI" = true ] && emoji="⚠️  "
    echo -e "${COLOR_YELLOW}${emoji}$*${COLOR_RESET}" >&2
}

error() {
    local emoji=""
    [ "$USE_EMOJI" = true ] && emoji="❌ "
    echo -e "${COLOR_RED}${emoji}ERROR: $*${COLOR_RESET}" >&2
}

# Print a header
print_header() {
    local title="$1"
    local width=80
    local padding=$(( (width - ${#title} - 2) / 2 ))
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_MAGENTA}"
    printf '═%.0s' $(seq 1 $width)
    echo ""
    printf "%*s %s %*s\n" $padding "" "$title" $padding ""
    printf '═%.0s' $(seq 1 $width)
    echo -e "${COLOR_RESET}"
    echo ""
}

# Cleanup function
cleanup() {
    if [ "$KEEP_TEMP" = false ] && [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        log "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Clean old temporary directories
clean_old_dirs() {
    info "Cleaning temporary directories older than $CLEAN_OLD_DAYS days..."
    local count=0
    if [ -d "./tmp" ]; then
        while IFS= read -r dir; do
            log "Removing old directory: $dir"
            rm -rf "$dir"
            ((count++))
        done < <(find ./tmp -maxdepth 1 -type d -name "geminictx_run_*" -mtime +$CLEAN_OLD_DAYS 2>/dev/null)
        
        if [ $count -gt 0 ]; then
            success "Cleaned $count old temporary directories"
        else
            info "No old temporary directories to clean"
        fi
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
        log "No timeout command found (install coreutils on macOS for gtimeout)"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and try again." >&2
        exit 1
    fi
    
    log "All prerequisites satisfied"
}

# ============================================================================
# PASS 1: BUILD THE SOPHISTICATED PROMPT
# ============================================================================

build_pass1_prompt() {
    local prompt_file="$1"
    local query="$2"
    local context_file="$3"
    
    log "Building Pass 1 prompt with sophisticated analysis structure..."
    
    # Create the prompt using the structure from /geminictx
    cat > "$prompt_file" << 'PROMPT_HEADER'
<task>
You are an expert scientist and staff level engineer. Your sole purpose is to analyze the provided codebase context and identify the most relevant files for answering the user's query. Do not answer the query yourself.

<steps>
<0>
Given the codebase context in `<codebase_context>`,
in a <scratchpad>, list the paths of all source code, documentation, test, and configuration files.
</0>

<1>
Analyze the user's `<query>`.
REVIEW PROJECT DOCUMENTATION
 - **Read CLAUDE.md thoroughly** - This contains essential project context, architecture, and known patterns
 - **Read DEVELOPER_GUIDE.md carefully** - This explains the development workflow, common issues, and debugging approaches
 - Review all architecture.md and all other high-level architecture documents
 - **Understand the project structure** from these documents before diving into the code
</1>

<2>
Think step-by-step about the user's query to form a complete understanding of the problem.
- **Hypothesize**: Formulate potential root causes based on the query (e.g., is it a data corruption issue, a configuration error, a logic bug in a specific function, or a regression?).
- **Investigate**: Use your hypotheses to guide a targeted analysis of the codebase, looking for evidence.
- **Synthesize**: Form a complete theory of the problem, identifying the key components, their interactions, and the sequence of events that leads to the failure.
- **Verify**: Review the `<codebase_context>` again to find specific evidence (code snippets, documentation, log messages) that confirms your theory.
</2>

<3>
For each relevant file you identify, provide your output in the strict format specified in `<output_format>`.
</3>
</steps>

<output_format>
Your output must contain the following sections in this exact order:

Section 0:
A list of the at least 25 files that are most relevant to the query (or all files, if there are fewer than 25). Each entry must follow this exact format.

FILE: [exact/path/to/file.ext]
SCORE: [A numeric score from 0.4 to 10.0, where 10 is the most relevant.]

Section 1: Thought Process
A detailed, step-by-step analysis of your reasoning. This section should explicitly include:
- **Initial Hypotheses**: What were your initial theories about the root cause of the problem?
- **Key Evidence**: What specific code snippets, documentation excerpts, or file relationships from the codebase led you to your conclusion?
- **Synthesized Root Cause**: A final, clear explanation of the chain of events causing the issue, referencing the key files involved.

Section 2: Data Flow and Component Analysis
A detailed analysis of all data flows, transformations, and component interactions relevant to the query.
- **Diagrams**: Use Mermaid syntax (e.g., `graph TD` for data flow or `sequenceDiagram` for call flows) to illustrate the problematic workflow.
- **Data Contracts**: Document critical data contracts in markdown tables. The table should include columns for: **Data**, **Source Component**, **Destination Component**, **Shape**, **Dtype**, and **Description**. Focus on the data being passed between the components you identified as most relevant.
- **Formulas/Pseudocode**: Use mathematical formulas or pseudocode to clarify key physical models or data transformations (e.g., `Intensity = |FFT(Probe * Object_patch)|^2`).

Section 3: Curated File List
A curated list of final entries (i.e. a subset of the files in Section 0). Each entry MUST follow this exact format, ending with three dashes on a new line.

FILE: [exact/path/to/file.ext]
RELEVANCE: [A concise, one-sentence explanation of why this file is relevant.]
SCORE: [A numeric score from 0.4 to 10.0, where 10 is the most relevant.]
---

Do not use tools. Your job is to do analysis, not an intervention.
</output_format>

<instructions>
think hard before you answer.
</instructions>
</task>
PROMPT_HEADER
    
    # Append the user query
    echo "" >> "$prompt_file"
    echo "<query>" >> "$prompt_file"
    echo "$query" >> "$prompt_file"
    echo "</query>" >> "$prompt_file"
    echo "" >> "$prompt_file"
    
    # Append the codebase context
    echo "<codebase_context>" >> "$prompt_file"
    cat "$context_file" >> "$prompt_file"
    echo "</codebase_context>" >> "$prompt_file"
    
    log "Pass 1 prompt built successfully"
}

# ============================================================================
# PASS 2: PROCESS IDENTIFIED FILES
# ============================================================================

process_pass2_display() {
    local file_list_file="$1"
    
    print_header "IDENTIFIED RELEVANT FILES"
    
    if [ ! -s "$file_list_file" ]; then
        warning "No files were identified in Pass 1"
        return
    fi
    
    echo -e "${COLOR_BOLD}The following files were identified as relevant to your query:${COLOR_RESET}"
    echo ""
    
    local count=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^FILE:[[:space:]](.+)$ ]]; then
            local file="${BASH_REMATCH[1]}"
            ((count++))
            
            # Read the next two lines for RELEVANCE and SCORE
            IFS= read -r relevance_line
            IFS= read -r score_line
            IFS= read -r separator  # Read the "---" separator
            
            local relevance="(no description)"
            local score="0.0"
            
            if [[ "$relevance_line" =~ ^RELEVANCE:[[:space:]](.+)$ ]]; then
                relevance="${BASH_REMATCH[1]}"
            fi
            
            if [[ "$score_line" =~ ^SCORE:[[:space:]]([0-9.]+)$ ]]; then
                score="${BASH_REMATCH[1]}"
            fi
            
            # Format score with color based on value
            local score_color="$COLOR_YELLOW"
            if (( $(echo "$score >= 8.0" | bc -l) )); then
                score_color="$COLOR_GREEN"
            elif (( $(echo "$score >= 5.0" | bc -l) )); then
                score_color="$COLOR_CYAN"
            fi
            
            printf "${COLOR_BOLD}%2d.${COLOR_RESET} ${COLOR_MAGENTA}%-50s${COLOR_RESET} ${score_color}[%.1f]${COLOR_RESET}\n" \
                   "$count" "$file" "$score"
            printf "    ${COLOR_CYAN}%s${COLOR_RESET}\n" "$relevance"
            echo ""
            
            # Limit the number of files displayed
            if [ $count -ge $MAX_FILES_TO_PROCESS ]; then
                info "Showing top $MAX_FILES_TO_PROCESS files (use -m to change limit)"
                break
            fi
        fi
    done < "$file_list_file"
    
    success "Identified $count relevant files"
}

process_pass2_content() {
    local file_list_file="$1"
    local response_file="$2"
    
    print_header "EXTRACTING FILE CONTENTS"
    
    if [ ! -s "$file_list_file" ]; then
        warning "No files were identified in Pass 1"
        return
    fi
    
    local count=0
    local output_file="${response_file%.txt}_contents.md"
    
    echo "# File Contents for Query: $USER_QUERY" > "$output_file"
    echo "" >> "$output_file"
    echo "Generated: $(date)" >> "$output_file"
    echo "" >> "$output_file"
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^FILE:[[:space:]](.+)$ ]]; then
            local file="${BASH_REMATCH[1]}"
            ((count++))
            
            # Skip RELEVANCE, SCORE, and separator lines
            IFS= read -r relevance_line
            IFS= read -r score_line
            IFS= read -r separator
            
            if [ -f "$file" ]; then
                log "Reading content of: $file"
                echo "## File $count: \`$file\`" >> "$output_file"
                echo "" >> "$output_file"
                echo '```' >> "$output_file"
                cat "$file" >> "$output_file" 2>/dev/null || echo "(Unable to read file)" >> "$output_file"
                echo '```' >> "$output_file"
                echo "" >> "$output_file"
                echo "---" >> "$output_file"
                echo "" >> "$output_file"
            else
                warning "File not found: $file"
                echo "## File $count: \`$file\` (NOT FOUND)" >> "$output_file"
                echo "" >> "$output_file"
            fi
            
            if [ $count -ge $MAX_FILES_TO_PROCESS ]; then
                info "Processed $MAX_FILES_TO_PROCESS files (use -m to change limit)"
                break
            fi
        fi
    done < "$file_list_file"
    
    success "Extracted content from $count files"
    info "Content saved to: $output_file"
    
    if [ "$VERBOSE" = false ]; then
        # Show a preview of the output
        echo ""
        echo "Preview of extracted content:"
        head -n 50 "$output_file"
        echo "..."
        echo "(Full content saved to $output_file)"
    fi
}

process_pass2_prompt() {
    local file_list_file="$1"
    local response_file="$2"
    local gemini_response="$3"
    
    print_header "CREATING SYNTHESIS PROMPT"
    
    if [ ! -s "$file_list_file" ]; then
        warning "No files were identified in Pass 1"
        return
    fi
    
    local prompt_file="${response_file%.txt}_synthesis_prompt.md"
    
    # Create the synthesis prompt header
    cat > "$prompt_file" << SYNTHESIS_HEADER
# Synthesis Task

## Original Query
$USER_QUERY

## Context
Gemini has analyzed the codebase and identified the most relevant files for answering this query. Below you'll find:
1. Gemini's analysis and reasoning
2. The complete content of the identified files

Please synthesize this information to provide a comprehensive answer to the query.

---

## Gemini's Analysis

SYNTHESIS_HEADER
    
    # Include relevant sections from Gemini's response
    awk '/^Section 1: Thought Process/,/^Section 2:/' "$gemini_response" >> "$prompt_file"
    echo "" >> "$prompt_file"
    awk '/^Section 2: Data Flow/,/^Section 3:/' "$gemini_response" >> "$prompt_file"
    echo "" >> "$prompt_file"
    
    echo "---" >> "$prompt_file"
    echo "" >> "$prompt_file"
    echo "## Identified Files and Their Contents" >> "$prompt_file"
    echo "" >> "$prompt_file"
    
    # Add file contents
    local count=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^FILE:[[:space:]](.+)$ ]]; then
            local file="${BASH_REMATCH[1]}"
            ((count++))
            
            # Read relevance and score
            IFS= read -r relevance_line
            IFS= read -r score_line
            IFS= read -r separator
            
            local relevance="(no description)"
            if [[ "$relevance_line" =~ ^RELEVANCE:[[:space:]](.+)$ ]]; then
                relevance="${BASH_REMATCH[1]}"
            fi
            
            echo "### File $count: \`$file\`" >> "$prompt_file"
            echo "**Relevance:** $relevance" >> "$prompt_file"
            echo "" >> "$prompt_file"
            
            if [ -f "$file" ]; then
                # Detect file type for syntax highlighting
                local lang=""
                case "$file" in
                    *.py) lang="python" ;;
                    *.js) lang="javascript" ;;
                    *.ts|*.tsx) lang="typescript" ;;
                    *.c|*.h) lang="c" ;;
                    *.cpp|*.hpp) lang="cpp" ;;
                    *.sh) lang="bash" ;;
                    *.md) lang="markdown" ;;
                    *.json) lang="json" ;;
                    *.yaml|*.yml) lang="yaml" ;;
                    *) lang="" ;;
                esac
                
                echo "\`\`\`$lang" >> "$prompt_file"
                cat "$file" >> "$prompt_file" 2>/dev/null || echo "(Unable to read file)" >> "$prompt_file"
                echo "\`\`\`" >> "$prompt_file"
            else
                echo "*File not found*" >> "$prompt_file"
            fi
            
            echo "" >> "$prompt_file"
            echo "---" >> "$prompt_file"
            echo "" >> "$prompt_file"
            
            if [ $count -ge $MAX_FILES_TO_PROCESS ]; then
                echo "*Note: Limited to $MAX_FILES_TO_PROCESS files*" >> "$prompt_file"
                break
            fi
        fi
    done < "$file_list_file"
    
    # Add synthesis instructions
    cat >> "$prompt_file" << SYNTHESIS_FOOTER

---

## Synthesis Instructions

Based on the above analysis and file contents, please provide:

1. **Summary**: A clear, concise answer to the original query
2. **Detailed Explanation**: Walk through the relevant code sections explaining how they work
3. **Key Insights**: Important patterns, dependencies, or architectural decisions
4. **Potential Issues**: Any problems or areas for improvement you notice
5. **Recommendations**: Specific suggestions for the user's next steps

Focus on being accurate, specific, and actionable. Reference specific files and line numbers where appropriate.
SYNTHESIS_FOOTER
    
    success "Created synthesis prompt with $count files"
    info "Prompt saved to: $prompt_file"
    echo ""
    echo "You can now use this prompt with Claude:"
    echo "  claude -p \"@$prompt_file\""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Set up signal handlers for cleanup
    trap cleanup EXIT INT TERM
    
    # Clean old directories if requested
    if [ "$CLEAN_OLD" = true ]; then
        clean_old_dirs
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Create temporary directory
    if [ -z "$OUTPUT_DIR" ]; then
        TEMP_DIR="./tmp/geminictx_run_${TIMESTAMP}"
    else
        TEMP_DIR="$OUTPUT_DIR"
    fi
    
    mkdir -p "$TEMP_DIR"
    log "Using temporary directory: $TEMP_DIR"
    
    # Define file paths
    REPOMIX_OUTPUT="$TEMP_DIR/repomix-output.xml"
    PROMPT_FILE="$TEMP_DIR/gemini-pass1-prompt.md"
    RESPONSE_FILE="$TEMP_DIR/gemini-pass1-response.txt"
    FILE_LIST="$TEMP_DIR/identified-files.txt"
    
    # ========================================================================
    # STEP 1: Run repomix to aggregate codebase context
    # ========================================================================
    
    print_header "PASS 1: CONTEXT AGGREGATION"
    info "Aggregating codebase context with repomix..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: Would execute:"
        echo "npx repomix@latest . \\"
        echo "  --top-files-len $REPOMIX_TOP_FILES \\"
        echo "  --include \"$REPOMIX_INCLUDE\" \\"
        echo "  --ignore \"$REPOMIX_IGNORE\" \\"
        echo "  -o \"$REPOMIX_OUTPUT\""
    else
        log "Running: npx repomix@latest with include=$REPOMIX_INCLUDE"
        
        if [ "$VERBOSE" = true ]; then
            npx repomix@latest . \
                --top-files-len "$REPOMIX_TOP_FILES" \
                --include "$REPOMIX_INCLUDE" \
                --ignore "$REPOMIX_IGNORE" \
                -o "$REPOMIX_OUTPUT"
        else
            npx repomix@latest . \
                --top-files-len "$REPOMIX_TOP_FILES" \
                --include "$REPOMIX_INCLUDE" \
                --ignore "$REPOMIX_IGNORE" \
                -o "$REPOMIX_OUTPUT" 2>&1 | while read -r line; do
                    log "repomix: $line"
                done
        fi
        
        if [ ! -s "$REPOMIX_OUTPUT" ]; then
            error "Repomix failed to generate the codebase context"
            exit 1
        fi
        
        # Get file size for reporting
        CONTEXT_SIZE=$(du -h "$REPOMIX_OUTPUT" | cut -f1)
        success "Codebase context aggregated: $CONTEXT_SIZE"
    fi
    
    # ========================================================================
    # STEP 2: Build and execute Pass 1 with Gemini
    # ========================================================================
    
    print_header "PASS 1: FILE IDENTIFICATION"
    info "Building sophisticated analysis prompt..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: Would create prompt file at $PROMPT_FILE"
        echo "Query: $USER_QUERY"
    else
        build_pass1_prompt "$PROMPT_FILE" "$USER_QUERY" "$REPOMIX_OUTPUT"
        
        # Report prompt file size
        PROMPT_SIZE=$(du -h "$PROMPT_FILE" | cut -f1)
        log "Prompt file size: $PROMPT_SIZE"
        
        info "Executing Gemini analysis (this may take a minute)..."
        
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
        
        if [ "$gemini_success" = false ]; then
            error "Gemini command failed or timed out"
            if [ -s "$RESPONSE_FILE" ]; then
                echo "Error output:" >&2
                head -n 20 "$RESPONSE_FILE" >&2
            fi
            exit 1
        fi
        
        if [ ! -s "$RESPONSE_FILE" ]; then
            error "Gemini command succeeded but produced no output"
            exit 1
        fi
        
        success "Gemini analysis complete"
        
        # Parse Section 3 for file list
        log "Parsing Gemini's response for identified files..."
        awk '/^Section 3: Curated File List/,/^$/ {
            if (/^FILE: / || /^RELEVANCE: / || /^SCORE: / || /^---$/) print
        }' "$RESPONSE_FILE" > "$FILE_LIST"
        
        if [ ! -s "$FILE_LIST" ]; then
            warning "Gemini did not identify specific files in Section 3"
            echo "Checking for files in other sections..."
            
            # Fallback: try to extract from Section 0
            awk '/^Section 0:/,/^Section 1:/ {
                if (/^FILE: /) {
                    print
                    print "RELEVANCE: (from Section 0)"
                    getline
                    print
                    print "---"
                }
            }' "$RESPONSE_FILE" > "$FILE_LIST"
        fi
    fi
    
    # ========================================================================
    # STEP 3: Execute Pass 2 based on selected mode
    # ========================================================================
    
    if [ "$DRY_RUN" = false ]; then
        print_header "PASS 2: ${PASS2_MODE^^} MODE"
        
        case "$PASS2_MODE" in
            display)
                process_pass2_display "$FILE_LIST"
                ;;
            content)
                process_pass2_content "$FILE_LIST" "$RESPONSE_FILE"
                ;;
            prompt)
                process_pass2_prompt "$FILE_LIST" "$RESPONSE_FILE" "$RESPONSE_FILE"
                ;;
        esac
        
        # Final summary
        echo ""
        print_header "ANALYSIS COMPLETE"
        info "Output files saved in: $TEMP_DIR"
        echo "  • Gemini response: $RESPONSE_FILE"
        echo "  • Identified files: $FILE_LIST"
        echo "  • Repomix context: $REPOMIX_OUTPUT"
        
        if [ "$KEEP_TEMP" = true ]; then
            info "Temporary files retained (use -k flag)"
        else
            info "Temporary files will be cleaned up"
        fi
    fi
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

# Show version in verbose mode
if [ "$VERBOSE" = true ]; then
    log "$SCRIPT_NAME version $VERSION"
    log "Query: $USER_QUERY"
    log "Pass 2 mode: $PASS2_MODE"
fi

main "$@"