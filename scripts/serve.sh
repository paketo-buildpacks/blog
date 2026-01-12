#!/usr/bin/env bash

set -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BUILDPACKDIR="$(cd "${PROGDIR}/.." && pwd)"

# shellcheck source=SCRIPTDIR/.util/tools.sh
source "${PROGDIR}/.util/tools.sh"

# shellcheck source=SCRIPTDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

function main() {
  local token
  token=""

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

      "")
        # skip if the argument is empty
        shift 1
        ;;

      *)
        util::print::error "unknown argument \"${1}\""
    esac
  done

  tools::install "${token}"

  util::print::title "Starting Hugo server..."
  "${BUILDPACKDIR}/.bin/hugo" server -D
}

function usage() {
  cat <<-USAGE
serve.sh [OPTIONS]

Runs the Hugo development server.

OPTIONS
  --help   -h         prints the command usage
  --token  -t <token> Token used to download assets from GitHub (optional)
USAGE
}

main "${@:-}"

