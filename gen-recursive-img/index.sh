#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# https://github.com/b2ns/libshell
source libshell

Args_define "-d --depth" "Set the screenshot depth" "<int>" 5
Args_define "-h --help" "Show this help"
Args_parse "$@"

if Args_has "-h"; then
  Args_help
  exit 1
fi

declare scriptRoot=""
scriptRoot="$(Path_dirpath "${BASH_SOURCE[0]}")"

screenshot() {
  local filename="$1"
  local -i n="$2"

  IO_info "screenshot$n ..."

  node "$scriptRoot/screenshot.js" "$filename"

  IO_info "screenshot$n: $filename"
}

changeImgLink() {
  local date="$1"
  local readmeFile=""
  readmeFile="$scriptRoot/../README.md"
  IO_info "changeImgLink $date ..."
  sed -i 's/screenshot_.*\.png/screenshot_'"$date"'.png/' "$readmeFile"
  IO_info "changeImgLink $date done"
}

pushRepo() {
  date="$1"
  IO_info "pushRepo $date ..."
  git add README.md screenshot*
  git commit -m "screenshot at $date"
  git push --progress
  IO_info "pushRepo $date done"
}

main() {
  local -i depth=0
  depth=$(Args_get "-d")
  local wait=15
  local date=""
  local -i i=""
  for ((i = 0; i < depth; i++)); do
    if ((i > 0)); then
      IO_info "sleep $wait seconds ..."
      sleep "$wait"
    fi

    date=$(date +%Y_%m_%d__%H_%M_%S)
    rm screenshot*

    screenshot "screenshot_${date}.png" "$((i + 1))"

    changeImgLink "$date"

    pushRepo "$date"
  done

  IO_success "Done!"
}

main