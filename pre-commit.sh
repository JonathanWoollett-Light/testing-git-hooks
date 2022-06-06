# For every staged file
for i in $(git diff --name-only --cached); do
    # Get the extension
    filename=$(basename -- "$i")
    extension="${filename##*.}"
    if [ "$extension" = "rs" ]; then
        # Run `cargo fmt` for this file
        rustfmt $i --config format_code_in_doc_comments=true,format_strings=true,license_template_path=./license.txt,imports_granularity=Module,normalize_comments=true,normalize_doc_attributes=true,group_imports=StdExternalCrate
        # Run `cargo-clippy` for this file
        cargo-clippy $i -- -D warnings \
            -D clippy::as_conversions \
            -D clippy::map_err_ignore \
            -D clippy::large_types_passed_by_value \
            -D clippy::missing_docs_in_private_items \
            -D clippy::used_underscore_binding \
            -D clippy::wildcard_dependencies \
            -D clippy::wildcard_imports
    fi
    if [ "$extension" == "py" ]; then
        # Run `black` for this file
        black $i
    fi
    # Add changes to this file (as a result of formatting) to the commit.
    git add $i
done
