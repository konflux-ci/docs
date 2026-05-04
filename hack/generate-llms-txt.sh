#!/bin/bash
# Generates llms.txt for the Konflux documentation.
# Scans the Antora content tree (AsciiDoc modules) and produces a structured
# index following the llms.txt specification (https://llmstxt.org/).
#
# Usage:
#   generate-llms-txt.sh <output_file>
#
# Arguments:
#   output_file  - Output path for llms.txt (e.g., public/llms.txt)
#
# Environment:
#   RAW_GITHUB_BASE - Base URL for raw AsciiDoc links
#                     (default: https://raw.githubusercontent.com/konflux-ci/docs/main/modules)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULES_DIR="$ROOT_DIR/modules"
OUTPUT_FILE="${1:?Usage: generate-llms-txt.sh <output_file>}"
RAW_BASE="${RAW_GITHUB_BASE:-https://raw.githubusercontent.com/konflux-ci/docs/main/modules}"

[[ "$OUTPUT_FILE" != /* ]] && OUTPUT_FILE="$ROOT_DIR/$OUTPUT_FILE"

PRODUCT_NAME="Konflux"

subst_attrs() {
  sed "s/{ProductName}/${PRODUCT_NAME}/g; s/{ProductShortName}//g"
}

# Extract the :description: attribute from an AsciiDoc document header.
get_description() {
  local adoc_file="$1"
  sed -n '/^:description:[[:space:]]*/{ s/^:description:[[:space:]]*//; p; q; }' "$adoc_file" \
    | subst_attrs
}

# Read nav file paths from antora.yml in declaration order.
get_nav_files() {
  sed -n '/^nav:/,/^[^ -]/p' "$ROOT_DIR/antora.yml" \
    | grep '\.adoc' \
    | sed 's/^[[:space:]]*-[[:space:]]*//'
}

# Section heading override for the ROOT module.
section_heading_for() {
  local module="$1" line="$2"
  case "$module" in
    ROOT) echo "Docs" ;;
    *)
      if [[ "$line" =~ xref:[^[]+\[([^\]]+)\] ]]; then
        echo "${BASH_REMATCH[1]}" | subst_attrs
      else
        echo "${line#\* }" | subst_attrs
      fi
      ;;
  esac
}

mkdir -p "$(dirname "$OUTPUT_FILE")"

{
cat << 'HEADER'
# Konflux Documentation

> Konflux is an open-source platform for building, testing, and releasing applications with enterprise-grade software supply chain security. It automates CI/CD pipelines using Tekton, provides SLSA Build Level 3 provenance, integrates policy-based compliance checks with Conforma, and manages releases across environments — all on Kubernetes.

- Documentation site: https://konflux-ci.dev/docs/
- Source code: https://github.com/konflux-ci/docs
- Operator and installation docs: https://konflux-ci.dev/konflux-ci/docs/
HEADER

while IFS= read -r nav_path; do
  nav_file="$ROOT_DIR/$nav_path"
  [ -f "$nav_file" ] || continue

  module=$(echo "$nav_path" | sed 's|modules/\([^/]*\)/nav\.adoc|\1|')

  section_emitted=false
  declare -A seen_files=()

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^include:: ]] && continue
    [[ "$line" =~ ^// ]] && continue

    stars="${line%%[^*]*}"
    level=${#stars}

    # First top-level entry → section heading
    if [ "$level" -eq 1 ] && [ "$section_emitted" = false ]; then
      heading=$(section_heading_for "$module" "$line")
      printf '\n## %s\n\n' "$heading"
      section_emitted=true
      # Plain-text headings (no xref) have no page to link
      if [[ ! "$line" =~ xref: ]]; then
        continue
      fi
    fi

    # Process xref entries
    if [[ "$line" =~ xref:([^[]+)\[([^\]]+)\] ]]; then
      target="${BASH_REMATCH[1]}"
      label=$(echo "${BASH_REMATCH[2]}" | subst_attrs)

      # Skip fragment-only links (anchors within an already-linked page)
      [[ "$target" == *"#"* ]] && continue

      # Resolve cross-module references (e.g. end-to-end:building-olm.adoc)
      resolved_module="$module"
      file_target="$target"
      if [[ "$file_target" =~ ^([a-zA-Z_-]+):(.+)$ ]]; then
        resolved_module="${BASH_REMATCH[1]}"
        file_target="${BASH_REMATCH[2]}"
      fi
      file_target="${file_target#page\$}"

      # Deduplicate within the same module nav
      file_key="${resolved_module}/${file_target}"
      if [ -n "${seen_files[$file_key]+x}" ]; then
        continue
      fi
      seen_files[$file_key]=1

      adoc_file="$MODULES_DIR/$resolved_module/pages/$file_target"
      [ -f "$adoc_file" ] || continue

      url="${RAW_BASE}/${resolved_module}/pages/${file_target}"
      desc=$(get_description "$adoc_file")

      if [ -n "$desc" ]; then
        printf -- '- [%s](%s): %s\n' "$label" "$url" "$desc"
      else
        printf -- '- [%s](%s)\n' "$label" "$url"
      fi
    fi
  done < "$nav_file"

  unset seen_files
done < <(get_nav_files)

} > "$OUTPUT_FILE"

echo "Generated llms.txt → $OUTPUT_FILE"
