#!/bin/bash
# usage: ./antivirus-cron.sh dir malicious_dir
# same as antivirusd.sh but checks once, cron runs it every minute

DIR="$1"
MAL_DIR="$2"

# flagged extensions and keywords
EXTENSIONS=(".exe" ".bat" ".vbs" ".scr" ".ps1")
KEYWORDS=("virus" "trojan" "malware" "worm" "ransomware")

mkdir -p "$MAL_DIR"

is_malicious() {
    name=$(basename "$1")
    for ext in "${EXTENSIONS[@]}"; do
        if [[ "$name" == *"$ext" ]]; then
            return 0
        fi
    done
    for word in "${KEYWORDS[@]}"; do
        if grep -qi "$word" "$1"; then
            return 0
        fi
    done
    return 1
}

scan() {
    for file in "$DIR"/*; do
        [ -f "$file" ] || continue
        name=$(basename "$file")

        # skip files restored before (bonus 2)
        if [ -f whitelist.txt ] && grep -qxF "$name" whitelist.txt; then
            continue
        fi

        if is_malicious "$file"; then
            echo "$name is malicious and it is DELETED"
            cp "$file" "$MAL_DIR/$name" && rm "$file"
        fi
    done
}

ls -l "$DIR" > directory-info.new
if [ ! -f directory-info.last ] || ! cmp -s directory-info.new directory-info.last; then
    scan
    # take the listing again after the scan removed files
    ls -l "$DIR" > directory-info.last
fi
