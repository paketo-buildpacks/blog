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
  do_not_update="false"

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

      --do-not-update)
        do_not_update="${2}"
        shift 2
        ;;

      *)
        util::print::error "unknown argument \"${1}\""
    esac
  done

  mkdir -p "${dir}"
  util::tools::path::export "${dir}"

  local version current_version

  version="$(jq -r .hugo "$(dirname "${BASH_SOURCE[0]}")/tools.json")"
  version="${version#v}"

  if [[ -f "${dir}/hugo" ]]; then
    current_version="$("${dir}/hugo" version 2>/dev/null | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -1)"
    current_version="${current_version#v}"
  else
    current_version=""
  fi

  if [[ "${current_version}" == "${version}" ]]; then
    util::print::info "Using $("${dir}"/hugo version)"
    return
  fi

  if [[ "${current_version}" != "${version}" && "${do_not_update}" == "true" && "${current_version}" != "" ]]; then
    util::print::info "Skipping hugo update"
    return
  fi

  if [[ "${current_version}" != "${version}"  && "${do_not_update}" == "false" ]]; then
    util::print::info "Updating hugo to version:${version}"
    rm -f "${dir}/hugo"
  fi

  if [[ ! -f "${dir}/hugo" ]]; then
    local curl_args os arch os_arch tarball_url

    util::print::title "Installing hugo version:${version}"

    os=$(util::tools::os)
    arch=$(util::tools::arch --format-amd64-64bit)


    if [[ "${os}" == "linux" ]]; then
      curl_args=(
        "--fail"
        "--silent"
        "--location"
      )

      if [[ "${token}" != "" ]]; then
        curl_args+=("--header" "Authorization: Token ${token}")
      fi

      os_arch="${os}-${arch}"
      tarball_url="https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_${os_arch}.tar.gz"
      curl "${curl_args[@]}" "${tarball_url}" | tar xzf - -C "${dir}" hugo
      chmod +x "${dir}/hugo"
    elif [[ "${os}" == "darwin" ]]; then
      local brew_prefix

      if ! command -v brew >/dev/null 2>&1; then
        util::print::error "Homebrew is required to install Hugo ${version} when the release tarball is unavailable"
      fi

      # we always install the latest version of hugo
      # as brew does not support installing a specific version
      brew install hugo

      brew_prefix="$(brew --prefix hugo)"

      ln -sf "${brew_prefix}/bin/hugo" "${dir}/hugo"
    else
      util::print::error "Unsupported OS for Hugo install: ${os}"
      exit 1
    fi
  else
    util::print::info "Using $("${dir}"/hugo version)"
  fi
}
