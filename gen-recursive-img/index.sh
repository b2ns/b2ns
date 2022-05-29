#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../node_modules/@b2ns/libshell/libshell.sh"

Args_define "-d --depth" "Set the screenshot depth" "<int>" 1
Args_define "-h --help" "Show this help"
Args_parse "$@"

if Args_has "-h"; then
  Args_help
  exit 1
fi

declare __dirname=""
__dirname="$(Path_dirpath "${BASH_SOURCE[0]}")"

screenshot() {
  local filename="$1"
  local -i n="$2"

  IO_info "screenshot$n ..."

  node "$__dirname/screenshot.js" "$filename"

  IO_success "screenshot$n: $filename"
}

changeReadmeImgLink() {
  local date="$1"
  local readmeFile=""
  readmeFile="$__dirname/../README.md"
  IO_info "changeReadmeImgLink $date ..."
  sed -i 's/screenshot_.*\.png/screenshot_'"$date"'.png/' "$readmeFile"
  IO_success "changeReadmeImgLink $date done"
}

pushRepo() {
  date="$1"
  IO_info "pushRepo $date ..."
  git add README.md screenshot*
  git commit -m "screenshot at $date"
  git push --quiet
  IO_success "pushRepo $date done"
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

    rm -vf "$__dirname/../"screenshot_*.png

    date=$(date +%Y_%m_%d__%H_%M_%S)

    screenshot "screenshot_${date}.png" "$((i + 1))"

    changeReadmeImgLink "$date"

    pushRepo "$date"
  done

  IO_success "Done!"
}

main
