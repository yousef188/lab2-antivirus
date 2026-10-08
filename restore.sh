#!/bin/bash
# usage: ./restore.sh dir malicious_dir

DIR="$1"
MAL_DIR="$2"

while true; do
    files=()
    for f in "$MAL_DIR"/*; do
        [ -f "$f" ] && files+=("$f")
    done

    if [ ${#files[@]} -eq 0 ]; then
        echo "No malicious files to review."
        exit 0
    fi

    echo "Quarantined files:"
    for i in "${!files[@]}"; do
        echo "$((i + 1))) $(basename "${files[$i]}")"
    done

    read -p "Choose a file number: " num || exit 0
    if ! [[ "$num" =~ ^[1-9][0-9]*$ ]] || [ "$num" -gt ${#files[@]} ]; then
        echo "Invalid number."
        continue
    fi

    file="${files[$((num - 1))]}"
    name=$(basename "$file")

    echo "1) Restore (false positive)"
    echo "2) Delete permanently"
    echo "3) Leave it"
    read -p "Choose an option: " opt || exit 0

    case "$opt" in
        1)
            cp "$file" "$DIR/$name"
            rm "$file"
            # remember it as safe (bonus 2)
            echo "$name" >> whitelist.txt
            echo "Restored $name to $DIR."
            ;;
        2)
            rm "$file"
            echo "$name permanently deleted."
            ;;
        3)
            ;;
    esac
done
