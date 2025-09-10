#!/usr/bin/env python3
"""
geminictx.py - Two-pass AI workflow for comprehensive codebase analysis

Pass 1: Gemini identifies relevant files from aggregated context
Pass 2: Process identified files (display, extract content, or create synthesis prompt)

Usage: ./geminictx.py "Your query about the codebase"
Example: ./geminictx.py "How does the authentication system work?"
"""

import argparse
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
from pathlib import Path
from typing import List, Optional, Tuple, Dict, Any
from textwrap import dedent, wrap

# Version information
__version__ = "2.0.0"

# Default configuration
DEFAULT_CONFIG = {
    "repomix_include": "**/*.{js,py,md,sh,json,c,h,yml,yaml,toml,rs,go,cpp,hpp,ts,tsx,jsx}",
    "repomix_ignore": "build/**,node_modules/**,dist/**,*.lock,.claude/**,venv/**,__pycache__/**,*.pyc,tmp/**,temp/**,trash/**,.git/**,PtychoNN/**,torch/**",
    "repomix_top_files": 20,
    "max_files_to_process": 25,
    "clean_old_days": 7,
    "gemini_timeout": 600,  # 10 minutes
}

# ANSI color codes
class Colors:
    """ANSI color codes for terminal output"""
    RESET = '\033[0m'
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[0;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    
    @classmethod
    def disable(cls):
        """Disable colors for non-terminal output"""
        for attr in dir(cls):
            if not attr.startswith('_') and attr != 'disable':
                setattr(cls, attr, '')

class Pass2Mode(Enum):
    """Pass 2 processing modes"""
    DISPLAY = "display"   # Show list of identified files with relevance
    CONTENT = "content"   # Output full content of identified files
    PROMPT = "prompt"     # Create synthesis prompt file for Claude

@dataclass
class FileInfo:
    """Information about an identified file"""
    path: str
    relevance: str = "(no description)"
    score: float = 0.0
    
    def __post_init__(self):
        """Validate and convert score to float"""
        if isinstance(self.score, str):
            try:
                self.score = float(self.score)
            except ValueError:
                self.score = 0.0

@dataclass
class AnalysisResult:
    """Results from the two-pass analysis"""
    query: str
    identified_files: List[FileInfo] = field(default_factory=list)
    gemini_analysis: str = ""
    thought_process: str = ""
    data_flow_analysis: str = ""
    timestamp: datetime = field(default_factory=datetime.now)
    output_dir: Path = None

class GeminiContextAnalyzer:
    """Main analyzer class for two-pass codebase analysis"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = self._setup_logging()
        self.temp_dir: Optional[Path] = None
        self.use_emoji = config.get('use_emoji', True)
        
    def _setup_logging(self) -> logging.Logger:
        """Configure logging based on verbosity"""
        level = logging.DEBUG if self.config.get('verbose', False) else logging.INFO
        
        # Create custom formatter
        formatter = logging.Formatter(
            f'{Colors.CYAN}[%(asctime)s]{Colors.RESET} %(message)s',
            datefmt='%H:%M:%S'
        )
        
        # Configure console handler
        handler = logging.StreamHandler()
        handler.setFormatter(formatter)
        
        # Configure logger
        logger = logging.getLogger(__name__)
        logger.setLevel(level)
        logger.handlers = [handler]  # Replace any existing handlers
        
        return logger
    
    def _run_command(self, cmd: List[str], timeout: Optional[int] = None, 
                    capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a shell command with timeout and error handling"""
        self.logger.debug(f"Running: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=capture_output,
                text=True,
                timeout=timeout,
                check=True
            )
            return result
        except subprocess.TimeoutExpired as e:
            self.error(f"Command timed out after {timeout} seconds: {' '.join(cmd)}")
            raise
        except subprocess.CalledProcessError as e:
            self.error(f"Command failed: {' '.join(cmd)}")
            if e.stderr:
                self.logger.error(f"Error output: {e.stderr}")
            raise
        except FileNotFoundError:
            self.error(f"Command not found: {cmd[0]}")
            raise
    
    def info(self, message: str):
        """Display info message with optional emoji"""
        emoji = "ℹ️  " if self.use_emoji else ""
        print(f"{Colors.BLUE}{emoji}{message}{Colors.RESET}")
    
    def success(self, message: str):
        """Display success message with optional emoji"""
        emoji = "✅ " if self.use_emoji else ""
        print(f"{Colors.GREEN}{emoji}{message}{Colors.RESET}")
    
    def warning(self, message: str):
        """Display warning message with optional emoji"""
        emoji = "⚠️  " if self.use_emoji else ""
        print(f"{Colors.YELLOW}{emoji}{message}{Colors.RESET}", file=sys.stderr)
    
    def error(self, message: str):
        """Display error message with optional emoji"""
        emoji = "❌ " if self.use_emoji else ""
        print(f"{Colors.RED}{emoji}ERROR: {message}{Colors.RESET}", file=sys.stderr)
    
    def print_header(self, title: str):
        """Print a formatted header"""
        width = 80
        padding = (width - len(title) - 2) // 2
        print()
        print(f"{Colors.BOLD}{Colors.MAGENTA}")
        print("═" * width)
        print(f"{' ' * padding} {title} {' ' * padding}")
        print("═" * width)
        print(f"{Colors.RESET}")
        print()
    
    def check_prerequisites(self) -> bool:
        """Check if required tools are available"""
        missing_tools = []
        
        # Check for npx (Node.js)
        if not shutil.which('npx'):
            missing_tools.append("npx (Node.js)")
        
        # Check for gemini CLI
        if not shutil.which('gemini'):
            missing_tools.append("gemini (Gemini CLI)")
        
        if missing_tools:
            self.error(f"Missing required tools: {', '.join(missing_tools)}")
            print("Please install the missing tools and try again.", file=sys.stderr)
            return False
        
        self.logger.debug("All prerequisites satisfied")
        return True
    
    def clean_old_directories(self):
        """Clean temporary directories older than configured days"""
        tmp_dir = Path("./tmp")
        if not tmp_dir.exists():
            return
        
        cutoff_date = datetime.now() - timedelta(days=self.config['clean_old_days'])
        count = 0
        
        for dir_path in tmp_dir.glob("geminictx_run_*"):
            if dir_path.is_dir():
                # Parse timestamp from directory name
                try:
                    dir_timestamp = datetime.strptime(
                        dir_path.name.replace("geminictx_run_", ""),
                        "%Y%m%d_%H%M%S"
                    )
                    if dir_timestamp < cutoff_date:
                        self.logger.debug(f"Removing old directory: {dir_path}")
                        shutil.rmtree(dir_path)
                        count += 1
                except (ValueError, OSError) as e:
                    self.logger.debug(f"Skipping {dir_path}: {e}")
        
        if count > 0:
            self.success(f"Cleaned {count} old temporary directories")
        else:
            self.info("No old temporary directories to clean")
    
    def setup_temp_directory(self) -> Path:
        """Create and return temporary directory for analysis"""
        if self.config.get('output_dir'):
            temp_dir = Path(self.config['output_dir'])
        else:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            temp_dir = Path(f"./tmp/geminictx_run_{timestamp}")
        
        temp_dir.mkdir(parents=True, exist_ok=True)
        self.logger.debug(f"Using temporary directory: {temp_dir}")
        return temp_dir
    
    def run_repomix(self, output_file: Path) -> bool:
        """Run repomix to aggregate codebase context"""
        self.info("Aggregating codebase context with repomix...")
        
        cmd = [
            "npx", "repomix@latest", ".",
            "--top-files-len", str(self.config['repomix_top_files']),
            "--include", self.config['repomix_include'],
            "--ignore", self.config['repomix_ignore'],
            "-o", str(output_file)
        ]
        
        try:
            if self.config.get('verbose'):
                # Show repomix output in verbose mode
                result = self._run_command(cmd, capture_output=False)
            else:
                # Capture output in normal mode
                result = self._run_command(cmd)
                if result.stderr:
                    self.logger.debug(f"repomix stderr: {result.stderr}")
            
            if output_file.exists() and output_file.stat().st_size > 0:
                size = output_file.stat().st_size / 1024  # KB
                if size > 1024:
                    size_str = f"{size/1024:.1f}M"
                else:
                    size_str = f"{size:.1f}K"
                self.success(f"Codebase context aggregated: {size_str}")
                return True
            else:
                self.error("Repomix failed to generate the codebase context")
                return False
                
        except Exception as e:
            self.error(f"Failed to run repomix: {e}")
            return False
    
    def build_pass1_prompt(self, query: str, context_file: Path) -> str:
        """Build the sophisticated Pass 1 prompt for Gemini"""
        self.logger.debug("Building Pass 1 prompt with sophisticated analysis structure...")
        
        # Read the context file
        context = context_file.read_text(encoding='utf-8', errors='ignore')
        
        prompt = dedent("""
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
            
            <query>
            {query}
            </query>
            
            <codebase_context>
            {context}
            </codebase_context>
        """).strip()
        
        return prompt.format(query=query, context=context)
    
    def run_gemini(self, prompt_file: Path) -> Optional[str]:
        """Execute Gemini with the prompt file"""
        self.info("Executing Gemini analysis (this may take a minute)...")
        
        cmd = [
            "gemini", "-p", 
            f"carefully complete the <task> in @{prompt_file}"
        ]
        
        try:
            result = self._run_command(
                cmd, 
                timeout=self.config.get('gemini_timeout', 600)
            )
            
            if result.stdout:
                self.success("Gemini analysis complete")
                return result.stdout
            else:
                self.error("Gemini command succeeded but produced no output")
                return None
                
        except subprocess.TimeoutExpired:
            self.error(f"Gemini timed out after {self.config.get('gemini_timeout', 600)} seconds")
            return None
        except Exception as e:
            self.error(f"Failed to run Gemini: {e}")
            return None
    
    def parse_gemini_response(self, response: str) -> AnalysisResult:
        """Parse Gemini's response to extract identified files and analysis"""
        result = AnalysisResult(query=self.config['query'])
        
        # Extract Section 1: Thought Process
        thought_match = re.search(
            r'Section 1: Thought Process(.*?)(?=Section 2:|$)',
            response, re.DOTALL
        )
        if thought_match:
            result.thought_process = thought_match.group(1).strip()
        
        # Extract Section 2: Data Flow and Component Analysis
        data_flow_match = re.search(
            r'Section 2: Data Flow.*?(.*?)(?=Section 3:|$)',
            response, re.DOTALL
        )
        if data_flow_match:
            result.data_flow_analysis = data_flow_match.group(1).strip()
        
        # Extract Section 3: Curated File List
        section3_match = re.search(
            r'Section 3: Curated File List(.*?)$',
            response, re.DOTALL
        )
        
        if section3_match:
            section3_content = section3_match.group(1)
            
            # Parse individual file entries
            file_pattern = re.compile(
                r'FILE:\s*(.+?)\n'
                r'RELEVANCE:\s*(.+?)\n'
                r'SCORE:\s*([\d.]+)\n'
                r'---',
                re.MULTILINE
            )
            
            for match in file_pattern.finditer(section3_content):
                file_info = FileInfo(
                    path=match.group(1).strip(),
                    relevance=match.group(2).strip(),
                    score=float(match.group(3))
                )
                result.identified_files.append(file_info)
        
        # Fallback: Try to extract from Section 0 if Section 3 is empty
        if not result.identified_files:
            self.logger.debug("No files in Section 3, trying Section 0...")
            section0_match = re.search(
                r'Section 0:(.*?)(?=Section 1:|$)',
                response, re.DOTALL
            )
            
            if section0_match:
                section0_content = section0_match.group(1)
                simple_pattern = re.compile(
                    r'FILE:\s*(.+?)\n'
                    r'SCORE:\s*([\d.]+)',
                    re.MULTILINE
                )
                
                for match in simple_pattern.finditer(section0_content):
                    file_info = FileInfo(
                        path=match.group(1).strip(),
                        relevance="(from Section 0)",
                        score=float(match.group(2))
                    )
                    result.identified_files.append(file_info)
        
        result.gemini_analysis = response
        return result
    
    def process_display_mode(self, result: AnalysisResult):
        """Display the identified files with scores and relevance"""
        self.print_header("IDENTIFIED RELEVANT FILES")
        
        if not result.identified_files:
            self.warning("No files were identified in Pass 1")
            return
        
        print(f"{Colors.BOLD}The following files were identified as relevant to your query:{Colors.RESET}")
        print()
        
        max_files = self.config['max_files_to_process']
        for i, file_info in enumerate(result.identified_files[:max_files], 1):
            # Color code based on score
            if file_info.score >= 8.0:
                score_color = Colors.GREEN
            elif file_info.score >= 5.0:
                score_color = Colors.CYAN
            else:
                score_color = Colors.YELLOW
            
            print(f"{Colors.BOLD}{i:2d}.{Colors.RESET} {Colors.MAGENTA}{file_info.path:<50}{Colors.RESET} "
                  f"{score_color}[{file_info.score:.1f}]{Colors.RESET}")
            
            # Wrap relevance text for readability
            wrapped_relevance = wrap(file_info.relevance, width=76, initial_indent="    ", 
                                    subsequent_indent="    ")
            for line in wrapped_relevance:
                print(f"{Colors.CYAN}{line}{Colors.RESET}")
            print()
        
        if len(result.identified_files) > max_files:
            self.info(f"Showing top {max_files} files (use -m to change limit)")
        
        self.success(f"Identified {len(result.identified_files)} relevant files")
    
    def process_content_mode(self, result: AnalysisResult):
        """Extract and save the content of identified files"""
        self.print_header("EXTRACTING FILE CONTENTS")
        
        if not result.identified_files:
            self.warning("No files were identified in Pass 1")
            return
        
        output_file = result.output_dir / "file_contents.md"
        max_files = self.config['max_files_to_process']
        
        with output_file.open('w', encoding='utf-8') as f:
            f.write(f"# File Contents for Query: {result.query}\n\n")
            f.write(f"Generated: {result.timestamp.strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            count = 0
            for file_info in result.identified_files[:max_files]:
                count += 1
                file_path = Path(file_info.path)
                
                f.write(f"## File {count}: `{file_info.path}`\n\n")
                f.write(f"**Relevance:** {file_info.relevance}\n")
                f.write(f"**Score:** {file_info.score:.1f}\n\n")
                
                if file_path.exists():
                    try:
                        content = file_path.read_text(encoding='utf-8', errors='ignore')
                        f.write("```\n")
                        f.write(content)
                        f.write("\n```\n\n")
                    except Exception as e:
                        f.write(f"*(Unable to read file: {e})*\n\n")
                else:
                    f.write("*(File not found)*\n\n")
                
                f.write("---\n\n")
        
        self.success(f"Extracted content from {count} files")
        self.info(f"Content saved to: {output_file}")
        
        # Show preview if not verbose
        if not self.config.get('verbose'):
            print("\nPreview of extracted content:")
            preview_lines = output_file.read_text().split('\n')[:50]
            for line in preview_lines:
                print(line)
            print("...")
            print(f"(Full content saved to {output_file})")
    
    def process_prompt_mode(self, result: AnalysisResult):
        """Create a synthesis prompt for Claude"""
        self.print_header("CREATING SYNTHESIS PROMPT")
        
        if not result.identified_files:
            self.warning("No files were identified in Pass 1")
            return
        
        output_file = result.output_dir / "synthesis_prompt.md"
        max_files = self.config['max_files_to_process']
        
        with output_file.open('w', encoding='utf-8') as f:
            # Write header
            f.write("# Synthesis Task\n\n")
            f.write(f"## Original Query\n{result.query}\n\n")
            f.write("## Context\n")
            f.write("Gemini has analyzed the codebase and identified the most relevant files ")
            f.write("for answering this query. Below you'll find:\n")
            f.write("1. Gemini's analysis and reasoning\n")
            f.write("2. The complete content of the identified files\n\n")
            f.write("Please synthesize this information to provide a comprehensive answer to the query.\n\n")
            f.write("---\n\n")
            
            # Include Gemini's analysis
            f.write("## Gemini's Analysis\n\n")
            if result.thought_process:
                f.write("### Thought Process\n")
                f.write(result.thought_process)
                f.write("\n\n")
            
            if result.data_flow_analysis:
                f.write("### Data Flow and Component Analysis\n")
                f.write(result.data_flow_analysis)
                f.write("\n\n")
            
            f.write("---\n\n")
            f.write("## Identified Files and Their Contents\n\n")
            
            # Add file contents
            count = 0
            for file_info in result.identified_files[:max_files]:
                count += 1
                file_path = Path(file_info.path)
                
                f.write(f"### File {count}: `{file_info.path}`\n")
                f.write(f"**Relevance:** {file_info.relevance}\n\n")
                
                if file_path.exists():
                    # Detect language for syntax highlighting
                    ext = file_path.suffix.lower()
                    lang_map = {
                        '.py': 'python',
                        '.js': 'javascript',
                        '.ts': 'typescript',
                        '.tsx': 'typescript',
                        '.c': 'c',
                        '.h': 'c',
                        '.cpp': 'cpp',
                        '.hpp': 'cpp',
                        '.sh': 'bash',
                        '.md': 'markdown',
                        '.json': 'json',
                        '.yaml': 'yaml',
                        '.yml': 'yaml',
                    }
                    lang = lang_map.get(ext, '')
                    
                    try:
                        content = file_path.read_text(encoding='utf-8', errors='ignore')
                        f.write(f"```{lang}\n")
                        f.write(content)
                        f.write("\n```\n\n")
                    except Exception as e:
                        f.write(f"*(Unable to read file: {e})*\n\n")
                else:
                    f.write("*File not found*\n\n")
                
                f.write("---\n\n")
            
            # Add synthesis instructions
            f.write("## Synthesis Instructions\n\n")
            f.write("Based on the above analysis and file contents, please provide:\n\n")
            f.write("1. **Summary**: A clear, concise answer to the original query\n")
            f.write("2. **Detailed Explanation**: Walk through the relevant code sections explaining how they work\n")
            f.write("3. **Key Insights**: Important patterns, dependencies, or architectural decisions\n")
            f.write("4. **Potential Issues**: Any problems or areas for improvement you notice\n")
            f.write("5. **Recommendations**: Specific suggestions for the user's next steps\n\n")
            f.write("Focus on being accurate, specific, and actionable. ")
            f.write("Reference specific files and line numbers where appropriate.\n")
        
        self.success(f"Created synthesis prompt with {count} files")
        self.info(f"Prompt saved to: {output_file}")
        print()
        print("You can now use this prompt with Claude:")
        print(f"  claude -p \"@{output_file}\"")
    
    def run(self) -> int:
        """Main execution flow"""
        # Check prerequisites
        if not self.check_prerequisites():
            return 1
        
        # Clean old directories if requested
        if self.config.get('clean_old'):
            self.clean_old_directories()
        
        # Dry run mode
        if self.config.get('dry_run'):
            self.print_header("DRY RUN MODE")
            self.info("Would perform the following actions:")
            print(f"  1. Create temp directory: ./tmp/geminictx_run_TIMESTAMP")
            print(f"  2. Run repomix with include: {self.config['repomix_include']}")
            print(f"  3. Build Pass 1 prompt for query: {self.config['query']}")
            print(f"  4. Execute Gemini with timeout: {self.config.get('gemini_timeout', 600)}s")
            print(f"  5. Process results in {self.config['pass2_mode']} mode")
            return 0
        
        # Setup temporary directory
        self.temp_dir = self.setup_temp_directory()
        
        try:
            # Pass 1: Context aggregation and analysis
            self.print_header("PASS 1: CONTEXT AGGREGATION")
            
            repomix_output = self.temp_dir / "repomix-output.xml"
            if not self.run_repomix(repomix_output):
                return 1
            
            self.print_header("PASS 1: FILE IDENTIFICATION")
            self.info("Building sophisticated analysis prompt...")
            
            # Build and save prompt
            prompt = self.build_pass1_prompt(self.config['query'], repomix_output)
            prompt_file = self.temp_dir / "gemini-pass1-prompt.md"
            prompt_file.write_text(prompt, encoding='utf-8')
            
            # Report prompt size
            prompt_size = prompt_file.stat().st_size / 1024
            if prompt_size > 1024:
                size_str = f"{prompt_size/1024:.1f}M"
            else:
                size_str = f"{prompt_size:.1f}K"
            self.logger.debug(f"Prompt file size: {size_str}")
            
            # Run Gemini
            gemini_response = self.run_gemini(prompt_file)
            if not gemini_response:
                return 1
            
            # Save response
            response_file = self.temp_dir / "gemini-pass1-response.txt"
            response_file.write_text(gemini_response, encoding='utf-8')
            
            # Parse response
            result = self.parse_gemini_response(gemini_response)
            result.output_dir = self.temp_dir
            
            # Save identified files list
            files_list = self.temp_dir / "identified-files.txt"
            with files_list.open('w', encoding='utf-8') as f:
                for file_info in result.identified_files:
                    f.write(f"FILE: {file_info.path}\n")
                    f.write(f"RELEVANCE: {file_info.relevance}\n")
                    f.write(f"SCORE: {file_info.score}\n")
                    f.write("---\n")
            
            # Pass 2: Process based on mode
            mode = Pass2Mode(self.config['pass2_mode'])
            self.print_header(f"PASS 2: {mode.value.upper()} MODE")
            
            if mode == Pass2Mode.DISPLAY:
                self.process_display_mode(result)
            elif mode == Pass2Mode.CONTENT:
                self.process_content_mode(result)
            elif mode == Pass2Mode.PROMPT:
                self.process_prompt_mode(result)
            
            # Final summary
            self.print_header("ANALYSIS COMPLETE")
            self.info(f"Output files saved in: {self.temp_dir}")
            print(f"  • Gemini response: {response_file}")
            print(f"  • Identified files: {files_list}")
            print(f"  • Repomix context: {repomix_output}")
            
            if self.config.get('keep_temp'):
                self.info("Temporary files retained (use -k flag)")
            else:
                self.info("Temporary files will be cleaned up")
            
            return 0
            
        except KeyboardInterrupt:
            self.warning("Interrupted by user")
            return 130
        except Exception as e:
            self.error(f"Unexpected error: {e}")
            if self.config.get('verbose'):
                import traceback
                traceback.print_exc()
            return 1
        finally:
            # Cleanup if not keeping temp files
            if not self.config.get('keep_temp') and self.temp_dir and self.temp_dir.exists():
                self.logger.debug(f"Cleaning up {self.temp_dir}")
                try:
                    shutil.rmtree(self.temp_dir)
                except Exception as e:
                    self.logger.debug(f"Failed to cleanup: {e}")

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Two-pass AI workflow for comprehensive codebase analysis",
        epilog="Example: %(prog)s \"How does the authentication system work?\"",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        'query',
        help='Your query about the codebase'
    )
    
    parser.add_argument(
        '-o', '--output',
        dest='output_dir',
        help='Output directory for artifacts (default: ./tmp/geminictx_run_TIMESTAMP)'
    )
    
    parser.add_argument(
        '-i', '--include',
        dest='repomix_include',
        help='File patterns to include (default: common code files)'
    )
    
    parser.add_argument(
        '-x', '--exclude',
        dest='repomix_ignore',
        help='File patterns to exclude (default: build artifacts, dependencies)'
    )
    
    parser.add_argument(
        '-t', '--top-files',
        dest='repomix_top_files',
        type=int,
        help='Number of top files to include (default: 20)'
    )
    
    parser.add_argument(
        '-m', '--max-files',
        dest='max_files_to_process',
        type=int,
        help='Maximum files to process in Pass 2 (default: 25)'
    )
    
    parser.add_argument(
        '-p', '--pass2',
        dest='pass2_mode',
        choices=['display', 'content', 'prompt'],
        default='display',
        help='Pass 2 mode: display, content, or prompt (default: display)'
    )
    
    parser.add_argument(
        '-k', '--keep',
        dest='keep_temp',
        action='store_true',
        help='Keep temporary files after completion'
    )
    
    parser.add_argument(
        '-c', '--clean-old',
        dest='clean_old',
        action='store_true',
        help='Clean temp directories older than 7 days'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output for debugging'
    )
    
    parser.add_argument(
        '--dry-run',
        dest='dry_run',
        action='store_true',
        help='Show what would be executed without running'
    )
    
    parser.add_argument(
        '--no-emoji',
        dest='use_emoji',
        action='store_false',
        help='Disable emoji in output'
    )
    
    parser.add_argument(
        '--no-color',
        dest='use_color',
        action='store_false',
        help='Disable colored output'
    )
    
    parser.add_argument(
        '--timeout',
        dest='gemini_timeout',
        type=int,
        help='Gemini timeout in seconds (default: 600)'
    )
    
    parser.add_argument(
        '--version',
        action='version',
        version=f'%(prog)s {__version__}'
    )
    
    args = parser.parse_args()
    
    # Disable colors if requested or if not in terminal
    if not args.use_color or not sys.stdout.isatty():
        Colors.disable()
    
    # Build configuration
    config = DEFAULT_CONFIG.copy()
    
    # Override with command line arguments
    for key, value in vars(args).items():
        if value is not None:
            config[key] = value
    
    # Override with environment variables
    for env_key, config_key in [
        ('REPOMIX_INCLUDE', 'repomix_include'),
        ('REPOMIX_IGNORE', 'repomix_ignore'),
        ('REPOMIX_TOP_FILES', 'repomix_top_files'),
        ('MAX_FILES_TO_PROCESS', 'max_files_to_process'),
        ('GEMINI_TIMEOUT', 'gemini_timeout'),
    ]:
        if env_key in os.environ:
            if config_key.endswith('_files') or config_key.endswith('timeout'):
                config[config_key] = int(os.environ[env_key])
            else:
                config[config_key] = os.environ[env_key]
    
    # Create analyzer and run
    analyzer = GeminiContextAnalyzer(config)
    return analyzer.run()

if __name__ == '__main__':
    sys.exit(main())