#!/bin/env bash
# Builds website sourced from local directories that might contain uncommitted
# changes and places the rendered HTML in the `public` directory, then proceeds
# to watch for any changes in the source files and rebuilds if they change.

set -o errexit
set -o pipefail
set -o nounset

ROOT_DIR="$(dirname "${BASH_SOURCE[0]}")/.."
(
    cd "${ROOT_DIR}"
    trap exit SIGINT
    # shellcheck disable=SC2016,SC2046
    while true; do
        find $(yq '.content.sources[].url | sub(".*/(.*)\.git", "../$1")' "${ROOT_DIR}/antora-playbook.yml") | entr -s 'echo Building ...; '"${ROOT_DIR}"/hack/local-build.sh'; echo Waiting for changes, press Ctrl+C to exit' || true
    done
)
