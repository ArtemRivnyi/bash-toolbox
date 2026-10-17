# Contributing to Bash Automation Toolbox

Thank you for helping expand our DevOps shell utilities library!

## 🚀 Guidelines for Adding New Scripts

1. Place new scripts in `scripts/` or project root.
2. Use POSIX-compliant bash syntax with strict error handling:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   ```
3. Include standard file header comments:
   * Script title
   * Description and usage examples
   * Author / Co-author attribution
4. Validate script syntax using ShellCheck before committing:
   ```bash
   shellcheck scripts/your-script.sh
   ```
5. Ensure scripts are executable (`chmod +x scripts/your-script.sh`).
