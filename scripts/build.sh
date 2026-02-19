#!/usr/bin/env bash

set -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOTDIR="$(cd "${PROGDIR}/.." && pwd)"

# shellcheck source=SCRIPTDIR/.util/tools.sh
source "${PROGDIR}/.util/tools.sh"

# shellcheck source=SCRIPTDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

function main() {
  local token
  token=""
  do_not_update="false"

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
      --help|-h)
        shift 1
        usage
        exit 0
        ;;

      --token|-t)
        token="${2}"
        shift 2
        ;;

      --do-not-update)
        do_not_update="true"
        shift 1
        ;;

      "")

        shift 1
        ;;

      *)
        util::print::error "unknown argument \"${1}\""
    esac
  done

  tools::install "${token}"

  util::print::title "Building Hugo site..."
  "${ROOTDIR}/.bin/hugo"

  util::print::success "Site built successfully!"
}

function usage() {
  cat <<-USAGE
build.sh [OPTIONS]

Builds the Hugo site.

OPTIONS
  --help   -h         prints the command usage
  --token  -t <token> Token used to download assets from GitHub (optional)
USAGE
}

function tools::install() {
  local token
  token="${1}"

  util::tools::hugo::install \
    --directory "${ROOTDIR}/.bin" \
    --token "${token}" \
    --do-not-update "${do_not_update}"
}

main "${@:-}"

