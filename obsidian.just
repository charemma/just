set fallback := true

# Obsidian-Helpers fuer den Bewerbungs-Workflow.
# Override Vault-Pfad per env BEWERBUNG_NOTES_ROOT.
_notes_root := env_var_or_default("BEWERBUNG_NOTES_ROOT", env_var("HOME") + "/Documents/Notes/1 Projects/Bewerbung Projekt")

# Find a note path by frontmatter `id`. Prints the absolute path on stdout.
# Exits non-zero on 0 or >1 matches; details on stderr.
find id:
    #!/usr/bin/env bash
    set -euo pipefail
    matches=$(grep -lr "^id: {{ id }}\$" "{{ _notes_root }}" 2>/dev/null || true)
    if [[ -z "$matches" ]]; then
        echo "ABORT: keine Notiz mit id={{ id }} in {{ _notes_root }}" >&2
        exit 1
    fi
    count=$(printf '%s\n' "$matches" | wc -l)
    if [[ "$count" -gt 1 ]]; then
        echo "ABORT: mehrere Treffer fuer id={{ id }} -- Slug muss eindeutig sein:" >&2
        echo "$matches" >&2
        exit 1
    fi
    printf '%s\n' "$matches"

# Extract a frontmatter field from a note (by id). Prints the value or empty.
# Note: inlines `find` logic to avoid re-invoking `just` (the recipe runs from
# a nix store path when consumed via flake input -- no justfile in cwd there).
extract id field:
    #!/usr/bin/env bash
    set -euo pipefail
    matches=$(grep -lr "^id: {{ id }}\$" "{{ _notes_root }}" 2>/dev/null || true)
    if [[ -z "$matches" ]]; then
        echo "ABORT: keine Notiz mit id={{ id }} in {{ _notes_root }}" >&2
        exit 1
    fi
    count=$(printf '%s\n' "$matches" | wc -l)
    if [[ "$count" -gt 1 ]]; then
        echo "ABORT: mehrere Treffer fuer id={{ id }} -- Slug muss eindeutig sein:" >&2
        echo "$matches" >&2
        exit 1
    fi
    awk -v field="{{ field }}" '
        BEGIN { in_fm = 0 }
        /^---$/ { in_fm = !in_fm; if (in_fm == 0 && NR > 1) exit; next }
        in_fm && $0 ~ "^"field":" {
            sub("^"field": *", "")
            gsub(/^"|"$/, "")
            print
            exit
        }
    ' "$matches"
