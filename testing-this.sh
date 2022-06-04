for i in $(git diff --name-only --cached); do
    filename=$(basename -- "$i")
    extension="${filename##*.}"
    echo "extension: $extension"
    if [ "$extension" = "rs" ]; then
        rustfmt $i
        cargo-clippy $i -- -D warnings
        git add $i
    fi
    if [ "$extension" == "py" ]; then
        black $i
        git add $i
    fi
done