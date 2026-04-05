# Directory to Text Script

Flatten selected parts of a codebase into a single Markdown file for review or LLM analysis.

---

## ⚠️ Security & Privacy

This script will dump file contents into a single document. Be careful what you include, and where you pass it, and take advice if you are unsure about any of this stuff.

### Do NOT include

- Secrets (API keys, tokens, passwords)
- `.env` files or credentials
- Private keys or certificates
- Production config files with sensitive data
- Proprietary or confidential code you are not allowed to share

### Be aware

- The output file is plain text and easy to copy, upload, or leak
- Pasting into tools (e.g. ChatGPT, GitHub, Slack) may expose data externally
- LLM tools may retain or process submitted content depending on settings

### Recommended precautions

- Add exclusions for sensitive files:
  ```bash
  ! -name "*.env" ! -name "*.pem" ! -name "*.key"
  ```
  - Review the output file before sharing
  - Use a sanitised version of your repo if unsure
  - Prefer dumping only specific directories (e.g. src, helm, terraform)

## What it does

- Scans directories you specify
- Excludes junk (`.git`, `target`, `node_modules`, etc.)
- Skips binary files
- Sorts files for stable output
- Adds a header before each file
- Wraps content in Markdown code blocks

Output: `repo_dump_for_llm.md`

---

## Usage

```bash
./dump-repo.sh <dir1> [dir2 ...]    

## Examples

```bash
./dump-repo.sh src/main/java src/test/java
./dump-repo.sh helm terraform
./dump-repo.sh src pom.xml
```

Note that overlapping paths can duplicate files.

## Disclaimer

This script is provided for development and review purposes only.

You are responsible for:

ensuring no sensitive or confidential information is exposed
complying with your organisation’s security and data policies
verifying what is included before sharing the output

Use at your own risk.