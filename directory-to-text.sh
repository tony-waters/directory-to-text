#!/usr/bin/env bash

# Fail fast:
# -e  → exit on error
# -u  → error on undefined variables
# -o pipefail → catch errors inside pipes
set -euo pipefail

# Output file (Markdown so it's LLM / GitHub friendly)
OUTPUT="repo_dump_for_llm.md"

# ------------------------------------------------------------------------------
# STEP 1: Write a header to guide whoever (or whatever) reads this file
# This massively improves review quality when feeding into ChatGPT or humans
# ------------------------------------------------------------------------------

cat > "$OUTPUT" <<'EOF'
PROJECT DUMP FOR REVIEW

Notes for reviewer:
- Paths are shown before each file.
- Build artifacts and binaries are excluded.
- Files are sorted alphabetically.
- Review for: architecture, bugs, code smells, JPA issues, Spring Boot issues,
  test gaps, naming, cohesion, coupling, and production risks.

---
EOF

# ------------------------------------------------------------------------------
# STEP 2: Find all relevant files
#
# Key points:
# - Use -print0 to safely handle spaces/newlines in filenames
# - Explicitly exclude junk directories and binary artifacts
# ------------------------------------------------------------------------------

find . -type f \
  ! -path "*/.git/*" \
  ! -path "*/target/*" \
  ! -path "*/build/*" \
  ! -path "*/node_modules/*" \
  ! -path "*/dist/*" \
  ! -path "*/coverage/*" \
  ! -path "*/.idea/*" \
  ! -path "*/.vscode/*" \
  ! -path "*/.mvn/wrapper/*" \
  ! -path "*/tmp/*" \
  ! -path "*/logs/*" \
  ! -name "*.class" \
  ! -name "*.jar" \
  ! -name "*.war" \
  ! -name "*.ear" \
  ! -name "*.zip" \
  ! -name "*.tar" \
  ! -name "*.gz" \
  ! -name "*.png" \
  ! -name "*.jpg" \
  ! -name "*.jpeg" \
  ! -name "*.gif" \
  ! -name "*.webp" \
  ! -name "*.pdf" \
  ! -name "*.iml" \
  ! -name "*.log" \
  -print0 |

# ------------------------------------------------------------------------------
# STEP 3: Sort files for deterministic output
#
# Why this matters:
# - Stable diffs in Git
# - Easier comparison between runs
# ------------------------------------------------------------------------------

sort -z |

# ------------------------------------------------------------------------------
# STEP 4: Process each file safely
#
# - read -d '' → handles null-separated input
# - avoids breaking on spaces or weird filenames
# ------------------------------------------------------------------------------

while IFS= read -r -d '' file; do

  # --------------------------------------------------------------------------
  # STEP 4a: Skip binary files
  #
  # Even after filtering extensions, some binaries sneak in.
  # Dumping them will corrupt your output and waste tokens.
  # --------------------------------------------------------------------------

  if file --mime "$file" | grep -q 'charset=binary'; then
    continue
  fi

  # --------------------------------------------------------------------------
  # STEP 4b: Infer language for Markdown code fences
  #
  # This improves syntax highlighting AND helps LLMs interpret structure
  # --------------------------------------------------------------------------

  ext="${file##*.}"
  case "$ext" in
    java) lang="java" ;;
    xml) lang="xml" ;;
    yml|yaml) lang="yaml" ;;
    properties) lang="properties" ;;
    sql) lang="sql" ;;
    sh) lang="bash" ;;
    md) lang="markdown" ;;
    json) lang="json" ;;
    html) lang="html" ;;
    css) lang="css" ;;
    js) lang="javascript" ;;
    ts) lang="typescript" ;;
    txt) lang="text" ;;
    *) lang="" ;;  # unknown → no syntax hint
  esac

  # --------------------------------------------------------------------------
  # STEP 4c: Write file header
  #
  # Clear separation between files is critical for readability and parsing
  # --------------------------------------------------------------------------

  printf '\n---\nFILE: %s\n---\n' "$file" >> "$OUTPUT"

  # --------------------------------------------------------------------------
  # STEP 4d: Wrap content in Markdown code fences
  #
  # This:
  # - preserves formatting
  # - avoids accidental markdown parsing
  # - makes it LLM-friendly
  # --------------------------------------------------------------------------

  printf '```%s\n' "$lang" >> "$OUTPUT"
  cat "$file" >> "$OUTPUT"
  printf '\n```\n' >> "$OUTPUT"

done

# ------------------------------------------------------------------------------
# STEP 5: Final confirmation
# ------------------------------------------------------------------------------

echo "Created $OUTPUT"
