set fallback := true

# Web-Fetcher die hinter Bot-Schutz (z.B. Cloudflare JS-Challenge) durchkommen.
# Default: curl-impersonate-chrome mit Chrome 124 TLS/HTTP2-Fingerprint.
_default_bin := "curl_chrome124"

# Fetch a URL using curl-impersonate (Chrome fingerprint).
# Prints body to stdout, HTTP status to stderr. Non-zero on HTTP >= 400.
fetch url bin=_default_bin:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v {{ bin }} >/dev/null 2>&1; then
        echo "error: {{ bin }} nicht im PATH. Run inside 'nix develop' (curl-impersonate)." >&2
        exit 127
    fi
    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT
    code=$({{ bin }} -sL -o "$tmp" -w "%{http_code}" "{{ url }}")
    echo "HTTP $code" >&2
    if [[ "$code" -ge 400 ]]; then
        echo "error: HTTP $code fetching {{ url }}" >&2
        cat "$tmp" >&2
        exit 1
    fi
    cat "$tmp"
