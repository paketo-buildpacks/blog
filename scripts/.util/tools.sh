#!/usr/bin/env bash

set -eu
set -o pipefail

# shellcheck source=SCRIPTDIR/print.sh
source "$(dirname "${BASH_SOURCE[0]}")/print.sh"

function util::tools::os() {
  case "$(uname)" in
    "Darwin")
      echo "${1:-darwin}"
      ;;

    "Linux")
      echo "linux"
      ;;

    *)
      util::print::error "Unknown OS \"$(uname)\""
      exit 1
  esac
}

function util::tools::arch() {
  case "$(uname -m)" in
    arm64|aarch64)
      echo "arm64"
      ;;

    amd64|x86_64)
      if [[ "${1:-}" == "--blank-amd64" ]]; then
        echo ""
      elif [[ "${1:-}" == "--format-amd64-x86_64" ]]; then
        echo "x86_64"
      elif [[ "${1:-}" == "--format-amd64-x86-64" ]]; then
        echo "x86-64"
      elif [[ "${1:-}" == "--format-amd64-64bit" ]]; then
        echo "64bit"
      else
        echo "amd64"
      fi
      ;;

    *)
      util::print::error "Unknown Architecture \"$(uname -m)\""
      exit 1
  esac
}

function util::tools::path::export() {
  local dir
  dir="${1}"

  if ! echo "${PATH}" | grep -q "${dir}"; then
    PATH="${dir}:$PATH"
    export PATH
  fi
}

function util::tools::hugo::install() {
  local dir token
  token=""

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
      --directory)
        dir="${2}"
        shift 2
        ;;

      --token)
        token="${2}"
        shift 2
        ;;

      *)
        util::print::error "unknown argument \"${1}\""
    esac
  done

  mkdir -p "${dir}"
  util::tools::path::export "${dir}"

  if [[ ! -f "${dir}/hugo" ]]; then
    local version curl_args os arch

    version="$(jq -r .hugo "$(dirname "${BASH_SOURCE[0]}")/tools.json")"

    curl_args=(
      "--fail"
      "--silent"
      "--location"
    )

    if [[ "${token}" != "" ]]; then
      curl_args+=("--header" "Authorization: Token ${token}")
    fi

    util::print::title "Installing hugo ${version} (extended)"

    os=$(util::tools::os)
    arch=$(util::tools::arch --format-amd64-64bit)

    local version_without_v="${version#v}"
    local os_arch="${os}-${arch}"

    if [[ "${os}" == "darwin" ]]; then
      os_arch="darwin-universal"
    fi

    curl "${curl_args[@]}" \
      "https://github.com/gohugoio/hugo/releases/download/${version}/hugo_extended_${version_without_v}_${os_arch}.tar.gz" | \
        tar xzf - -C "${dir}" hugo

    chmod +x "${dir}/hugo"
  else
    util::print::info "Using $("${dir}"/hugo version)"
  fi
}

function tools::install() {
  local token
  token="${1:-}"

  util::tools::hugo::install \
    --directory "${BUILDPACKDIR}/.bin" \
    --token "${token}"
}

