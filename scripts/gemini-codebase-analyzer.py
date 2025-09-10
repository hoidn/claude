#!/usr/bin/env python3
"""
gemini-codebase-analyzer.py - Analyze codebases with Gemini using repomix for context aggregation

This script provides a streamlined single-pass analysis where Gemini directly answers your
question about the codebase after reading project documentation for context.

Usage: ./gemini-codebase-analyzer.py "Your question about the codebase"
Example: ./gemini-codebase-analyzer.py "Explain the authentication workflow"
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Dict, Any
from textwrap import dedent

# Version information
__version__ = "1.0.0"

# Default configuration
DEFAULT_CONFIG = {
    "repomix_include": "**/*.{js,py,md,sh,json,c,h,yml,yaml,toml,rs,go,cpp,hpp,ts,tsx,jsx}",
    "repomix_ignore": "build/**,node_modules/**,dist/**,*.lock,.claude/**,venv/**,__pycache__/**,*.pyc,tmp/**,temp/**,trash/**,.git/**",
    "repomix_top_files": 20,
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

class GeminiCodebaseAnalyzer:
    """Main analyzer class for single-pass codebase analysis with Gemini"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.temp_dir: Optional[Path] = None
        self.use_emoji = config.get('use_emoji', True)
        
    def _run_command(self, cmd: list[str], timeout: Optional[int] = None, 
                    capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a shell command with timeout and error handling"""
        if self.config.get('verbose'):
            self.log(f"Running: {' '.join(cmd)}")
        
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
                self.log(f"Error output: {e.stderr}")
            raise
        except FileNotFoundError:
            self.error(f"Command not found: {cmd[0]}")
            raise
    
    def log(self, message: str):
        """Display debug message in verbose mode"""
        if self.config.get('verbose'):
            timestamp = datetime.now().strftime('%H:%M:%S')
            print(f"{Colors.CYAN}[{timestamp}]{Colors.RESET} {message}", file=sys.stderr)
    
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
        
        self.log("All prerequisites satisfied")
        return True
    
    def clean_old_directories(self):
        """Clean temporary directories older than configured days"""
        tmp_dir = Path("./tmp")
        if not tmp_dir.exists():
            return
        
        cutoff_date = datetime.now() - timedelta(days=self.config['clean_old_days'])
        count = 0
        
        for dir_path in tmp_dir.glob("gemini_run_*"):
            if dir_path.is_dir():
                # Parse timestamp from directory name
                try:
                    dir_timestamp = datetime.strptime(
                        dir_path.name.replace("gemini_run_", ""),
                        "%Y%m%d_%H%M%S"
                    )
                    if dir_timestamp < cutoff_date:
                        self.log(f"Removing old directory: {dir_path}")
                        shutil.rmtree(dir_path)
                        count += 1
                except (ValueError, OSError) as e:
                    self.log(f"Skipping {dir_path}: {e}")
        
        if count > 0:
            self.success(f"Cleaned {count} old temporary directories")
    
    def setup_temp_directory(self) -> Path:
        """Create and return temporary directory for analysis"""
        if self.config.get('output_dir'):
            temp_dir = Path(self.config['output_dir'])
        else:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            temp_dir = Path(f"./tmp/gemini_run_{timestamp}")
        
        temp_dir.mkdir(parents=True, exist_ok=True)
        self.log(f"Using temporary directory: {temp_dir}")
        return temp_dir
    
    def run_repomix(self, output_file: Path) -> bool:
        """Run repomix to aggregate codebase context"""
        self.info("Step 1: Aggregating codebase context with repomix...")
        
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
                    self.log(f"repomix stderr: {result.stderr}")
            
            if output_file.exists() and output_file.stat().st_size > 0:
                size = output_file.stat().st_size / 1024  # KB
                if size > 1024:
                    size_str = f"{size/1024:.1f}M"
                else:
                    size_str = f"{size:.1f}K"
                self.success(f"Codebase context aggregated: {size_str} in {output_file}")
                return True
            else:
                self.error("Repomix failed to generate the codebase context")
                return False
                
        except Exception as e:
            self.error(f"Failed to run repomix: {e}")
            return False
    
    def build_prompt(self, task: str, context_file: Path) -> str:
        """Build the structured prompt for Gemini"""
        self.log("Building structured prompt with documentation-first approach...")
        
        # Read the context file
        context = context_file.read_text(encoding='utf-8', errors='ignore')
        
        prompt = dedent(f"""
            <task>
            You are an expert software engineer and architect tasked with analyzing a codebase to answer a specific question or complete a specific task.
            
            ## Your Task
            {task}
            
            ## Instructions
            
            ### Step 1: Read Project Documentation First (CRITICAL)
            Before analyzing any code, you MUST review the project documentation to understand the context, conventions, and architecture:
            
            - **CLAUDE.md** - Essential project context, conventions, and implementation guidelines
            - **README.md** - Project overview and setup instructions
            - **docs/** directory - Architecture documents, API specifications, design decisions
            - Any other .md files that explain the project structure, patterns, or workflows
            
            This context is ESSENTIAL. Code without understanding the project's conventions and architecture will lead to incorrect analysis.
            
            ### Step 2: Analyze the Codebase
            With the project context in mind, analyze the code to address the user's task:
            - Identify the relevant components and their relationships
            - Understand the data flow and dependencies
            - Note any patterns, conventions, or architectural decisions
            - Look for test files that demonstrate intended behavior
            - Analyze any session histories or archival documentation that contains information on previous attempts to solve the problem
            
            ### Step 3: Answer the User's Task
            Now, directly answer the user's specific question or complete their requested task. Your response should be practical, actionable, and directly relevant to what they asked for.
            
            ## Response Format
            
            Focus on answering the user's specific task. Don't provide generic analysis - address exactly what they asked for.
            
            For example:
            - If they asked "how does X work?" - explain the specific implementation of X
            - If they asked "find security issues" - list specific vulnerabilities you found
            - If they asked "explain the data flow" - trace the actual data flow they're asking about
            - If they asked "why does X fail?" - identify the specific root cause
            
            Include code snippets and file references to support your answer. Be direct and practical.
            
            ## About the Codebase Context
            
            The codebase context below is provided in XML format generated by repomix. It contains:
            - Complete file contents with their paths
            - Repository structure information
            - Documentation files that explain the project
            
            Pay special attention to:
            - Project documentation files (.md files, especially CLAUDE.md)
            - Configuration files that define project settings
            - Main entry points and core modules
            - Test files that show expected behavior
            - Comments and docstrings that explain implementation details
            
            </task>
            
            <codebase_context>
            {context}
            </codebase_context>
        """).strip()
        
        return prompt
    
    def run_gemini(self, prompt_file: Path) -> Optional[str]:
        """Execute Gemini with the prompt file"""
        self.info("Step 3: Executing Gemini analysis...")
        
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
            print(f"  1. Create temp directory: ./tmp/gemini_run_TIMESTAMP")
            print(f"  2. Run repomix with include: {self.config['repomix_include']}")
            print(f"  3. Build prompt for task: {self.config['task']}")
            print(f"  4. Execute Gemini with timeout: {self.config.get('gemini_timeout', 600)}s")
            return 0
        
        # Setup temporary directory
        self.temp_dir = self.setup_temp_directory()
        
        try:
            # Step 1: Run repomix to aggregate codebase context
            repomix_output = self.temp_dir / "repomix-output.xml"
            if not self.run_repomix(repomix_output):
                return 1
            
            # Step 2: Build and save prompt
            self.info("Step 2: Building structured prompt file...")
            prompt = self.build_prompt(self.config['task'], repomix_output)
            prompt_file = self.temp_dir / "gemini-prompt.md"
            prompt_file.write_text(prompt, encoding='utf-8')
            
            # Report prompt size
            prompt_size = prompt_file.stat().st_size / 1024
            if prompt_size > 1024:
                size_str = f"{prompt_size/1024:.1f}M"
            else:
                size_str = f"{prompt_size:.1f}K"
            self.success(f"Prompt file created: {prompt_file} ({size_str})")
            
            # Step 3: Run Gemini
            gemini_response = self.run_gemini(prompt_file)
            if not gemini_response:
                return 1
            
            # Save response
            response_file = self.temp_dir / "gemini-response.txt"
            response_file.write_text(gemini_response, encoding='utf-8')
            
            # Display the response
            self.print_header("GEMINI ANALYSIS RESULT")
            print(gemini_response)
            print()
            print("═" * 80)
            
            # Save locations
            self.info(f"Analysis saved to: {response_file}")
            self.info(f"Prompt file: {prompt_file}")
            self.info(f"Codebase context: {repomix_output}")
            
            if self.config.get('keep_temp'):
                self.info(f"Temporary files retained in: {self.temp_dir}")
            else:
                self.info("Temporary files will be cleaned up (use -k to keep)")
            
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
                self.log(f"Cleaning up {self.temp_dir}")
                try:
                    shutil.rmtree(self.temp_dir)
                except Exception as e:
                    self.log(f"Failed to cleanup: {e}")

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Analyze codebases with Gemini using repomix for context aggregation",
        epilog="Example: %(prog)s \"Explain the authentication workflow\"",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        'task',
        help='Your question or task for Gemini to complete'
    )
    
    parser.add_argument(
        '-o', '--output',
        dest='output_dir',
        help='Output directory for artifacts (default: ./tmp/gemini_run_TIMESTAMP)'
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
        ('GEMINI_TIMEOUT', 'gemini_timeout'),
    ]:
        if env_key in os.environ:
            if config_key.endswith('_files') or config_key.endswith('timeout'):
                config[config_key] = int(os.environ[env_key])
            else:
                config[config_key] = os.environ[env_key]
    
    # Create analyzer and run
    analyzer = GeminiCodebaseAnalyzer(config)
    return analyzer.run()

if __name__ == '__main__':
    sys.exit(main())