#!/usr/bin/env bash


function keep {
  OPTIND=1
  while getopts 'h' opt; do
    case "$opt" in
      h) _show_manual_for 'keep';;

      *) _invalid_option_for 'keep';;
    esac
  done

  shift $((OPTIND-1))
  [ "$1" = '--' ] && shift

  # Validate if user exists:
  _user_required

  # Command logic:

  # Firstly, hide the files to make sure they are up-to-date
  hide

  # Now securely remove the hidden files
  filenames=()
  _list_all_added_files  # exports 'filenames' array
  local filename
  for filename in "${filenames[@]}"; do
    local path=$(_append_root_path "$filename")
    if [[ -f "$path" ]]; then
      echo "shredding $filename"
      _os_based __shred_file "$path"
    fi
  done
  echo "done. all ${#filename[@]} files securely deleted"
}
