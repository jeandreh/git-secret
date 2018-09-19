#!/usr/bin/env bash


function keep {
  while getopts 'h' opt; do
    case "$opt" in
      h) _show_manual_for 'keep';;

      *) _invalid_option_for 'keep';;
    esac
  done

  # Validate if user exists:
  _user_required

  # Command logic:

  local path_mappings
  path_mappings=$(_get_secrets_dir_paths_mapping)

  for item in "$(cat path_mappings)"; do
    local path # absolute path
    local normalized_path # relative to .git folder
    normalized_path=$(_git_normalize_filename "$item")
    path=$(_append_root_path "$normalized_path")

    # Checking if file exists:
    if [[ ! -f "$path" ]]; then
      _abort "file not found: $item"
    fi

    _os_based __shred_file "$normalized_path"
    echo 'File $path successfully shredded.'

    # Deleting it from path mappings:
    # Remove record from fsdb with matching key
    local key
    key="$normalized_path"
    fsdb="$path_mappings"
    _fsdb_rm_record "$key" "$fsdb"

    rm -f "${path_mappings}.bak"  # not all systems create '.bak'
  done

  echo 'File $path removed from index.'
}
