#!/bin/bash
# Exit immediately when encountering a non-zero command
set -e 
# I don't think there is a reasonable way to do these more specifically
cargo audit
# For every staged file
for i in $(git diff --name-only --cached); do
    # Get the extension
    filename=$(basename -- "$i")
    extension="${filename##*.}"
    if [ "$extension" = "rs" ]; then
        # Maybe also consider https://crates.io/crates/cargo-spellcheck
        # TODO We need to have some discussion on what configs to use for `fmt` and `clippy`.
        
        # Read rustfmt config, replace '\n' with ','
        rustfmt_config_1="$(sed -z "s/\n/,/g;s/,$/\n/" fmt.toml)"
        # Remove '"'
        rustfmt_config_2="${rustfmt_config_1//\"}"
        # Run `cargo fmt` for this file
        rustfmt $i --config $rustfmt_config_2

        # Read clippy config, prefix ` -D clippy::` to each line
        clippy_config_1="$(sed -e 's/^/ -D clippy::/' clip.toml)"
        # Remove all instances of `=true\n`
        clippy_config_2="${clippy_config_1//$'=true\n'}"
        # Run `cargo-clippy` for this file
        cargo-clippy $i -- -D warnings $clippy_config_2
    fi
    if [ "$extension" == "py" ]; then
        # Run `black` for this file
        black $i
    fi
    # Add changes to this file (as a result of formatting) to the commit.
    git add $i
done

exit 1