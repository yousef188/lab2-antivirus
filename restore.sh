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


    echo "Choose a file:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)): $(basename "${files[$i]}")"
    done



    printf "> "
    read num || exit 0
    if ! [[ "$num" =~ ^[1-9][0-9]*$ ]] || [ "$num" -gt ${#files[@]} ]; then
        echo "Invalid number."
        continue
    fi


    file="${files[$((num - 1))]}"
    name=$(basename "$file")


    
    echo "For $name:"
    echo "1: Restore this file back into dir (it was a false positive)"
    echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
    echo "3: Go back"
    printf "> "
    read opt || exit 0
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
