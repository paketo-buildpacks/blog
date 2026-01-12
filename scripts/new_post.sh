#!/usr/bin/env bash
et -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BUILDPACKDIR="$(cd "${PROGDIR}/.." && pwd)"

# shellcheck source=SCRIPTDIR/.util/tools.sh
source "${PROGDIR}/.util/tools.sh"

# shellcheck source=SCRIPTDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

function main() {
  local token name
  token=""
  name=""

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

      --name)
        name="${2}"
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

  if [[ -z "${name}" ]]; then
    util::print::error "post name is required (use --name or -n)"
  fi

  tools::install "${token}"

  local post_file
  post_file="posts/${name}.md"

  util::print::title "Creating new post: ${post_file}"
  "${BUILDPACKDIR}/.bin/hugo" new "${post_file}"

  util::print::success "Post created: content/${post_file}"
}

function usage() {
  cat <<-USAGE
new.sh [OPTIONS]

Creates a new blog post.

OPTIONS
  --help   -h         prints the command usage
  --name      <name>  post name (required, e.g. "0038-my-new-post")
  --token  -t <token> Token used to download assets from GitHub (optional)

EXAMPLE
  ./scripts/new.sh --name 0038-my-new-post
  # Creates: content/posts/0038-my-new-post.md
USAGE
}

main "${@:-}"

