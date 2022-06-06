for i in $(git diff --name-only --cached); do
    filename=$(basename -- "$i")
    extension="${filename##*.}"
    if [ "$extension" = "rs" ]; then
        rustfmt $i --config format_code_in_doc_comments=true,format_strings=true,license_template_path=./license.txt,imports_granularity=Module,normalize_comments=true,normalize_doc_attributes=true,group_imports=StdExternalCrate

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
        black $i
    fi
    git add $i
done