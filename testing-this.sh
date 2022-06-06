for i in $(git diff --name-only --cached); do
    filename=$(basename -- "$i")
    extension="${filename##*.}"
    if [ "$extension" = "rs" ]; then
        rustfmt $i
        cargo-clippy $i -- -D warnings
    fi
    if [ "$extension" == "py" ]; then
        black $i
    fi
    git add $i
done
