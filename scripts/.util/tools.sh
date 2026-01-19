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

    local tarball_url
    tarball_url="https://github.com/gohugoio/hugo/releases/download/${version}/hugo_extended_${version_without_v}_${os_arch}.tar.gz"

    if curl "${curl_args[@]}" "${tarball_url}" | tar xzf - -C "${dir}" hugo 2>/dev/null; then
      chmod +x "${dir}/hugo"
    else
      util::print::warn "Tarball ${tarball_url} not available, attempting Homebrew install instead"
      util::tools::hugo::install_with_brew "${version_without_v}" "${dir}"
    fi
  else
    util::print::info "Using $("${dir}"/hugo version)"
  fi
}

function util::tools::hugo::install_with_brew() {
  local version dir formula install_formula brew_prefix
  version="${1}"
  dir="${2}"
  formula="hugo@${version}"
  install_formula="${formula}"

  if ! command -v brew >/dev/null 2>&1; then
    util::print::error "Homebrew is required to install Hugo ${version} when the release tarball is unavailable"
  fi

  if ! brew info "${formula}" >/dev/null 2>&1; then
    util::print::warn "Homebrew formula ${formula} not found, falling back to installing hugo"
    install_formula="hugo"
  fi

  util::print::title "Installing ${install_formula} via Homebrew"
  if ! brew list --versions "${install_formula}" >/dev/null 2>&1; then
    brew install "${install_formula}"
  fi

  brew_prefix="$(brew --prefix "${install_formula}")"

  if [[ ! -x "${brew_prefix}/bin/hugo" ]]; then
    util::print::error "Homebrew did not install a hugo binary at ${brew_prefix}/bin/hugo"
  fi

  ln -sf "${brew_prefix}/bin/hugo" "${dir}/hugo"

  if ! "${dir}/hugo" version | grep -q "v${version}"; then
    util::print::error "Homebrew installed $("${dir}"/hugo version) which does not match requested v${version}"
  fi
}
