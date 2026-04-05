#!/usr/bin/env bash
set -euo pipefail

OUTPUT="repo_dump_for_llm.md"

# ------------------------------------------------------------------------------
# INPUT VALIDATION
# - Require at least one directory
# ------------------------------------------------------------------------------

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <dir1> [dir2 ...]"
  exit 1
fi

# ------------------------------------------------------------------------------
# HEADER
# ------------------------------------------------------------------------------

cat > "$OUTPUT" <<'EOF'
PROJECT DUMP FOR REVIEW

Notes for reviewer:
- Only selected directories are included.
- Paths are shown before each file.
- Build artifacts and binaries are excluded.
- Files are sorted alphabetically.

---
EOF

# ------------------------------------------------------------------------------
# MAIN FIND
# - "$@" passes all input directories
# ------------------------------------------------------------------------------

find "$@" -type f \
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
  ! -name "*.tfstate" \
  ! -name "*.backup" \
  ! -name "*.lock.hcl" \
  ! -path "*/.terraform/*" \
  ! -name "*.md" \
  -print0 |
sort -z |
while IFS= read -r -d '' file; do

  # Skip binary files
  if file --mime "$file" | grep -q 'charset=binary'; then
    continue
  fi

  # Infer language
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
    *) lang="" ;;
  esac

  printf '\n---\nFILE: %s\n---\n' "$file" >> "$OUTPUT"
  printf '```%s\n' "$lang" >> "$OUTPUT"
  cat "$file" >> "$OUTPUT"
  printf '\n```\n' >> "$OUTPUT"

done

echo "Created $OUTPUT"