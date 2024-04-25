#!/bin/env bash
# Builds website sourced from local directories that might contain uncommitted
# changes and places the rendered HTML in the `public` directory.

set -o errexit
set -o pipefail
set -o nounset

ROOT_DIR="$(dirname "${BASH_SOURCE[0]}")/.."
PREVIEW_PLAYBOOK=$(mktemp preview.XXXXXXXXXX.yml)
# shellcheck disable=SC2064
trap "rm -f ${PREVIEW_PLAYBOOK}" EXIT

# shellcheck disable=SC2016
for dir in $(yq '.content.sources[] | .url |= sub(".*/(.*)\.git", "../$1") | .url + "/" + .start_path' "${ROOT_DIR}/antora-playbook.yml"); do
    if [ ! -d "${dir}" ]; then
        echo "Directory ${dir} doesn't exist, either create a symlink from that location to the expected repository or locally modify antora-playbook.yml to point to it"
        exit 1
    fi
done

cp "${ROOT_DIR}/antora-playbook.yml" "${PREVIEW_PLAYBOOK}"
# shellcheck disable=SC2016
yq e -i '.content.sources[].url |= sub(".*/(.*)\.git", "../$1") | .content.sources[].branches = "HEAD" | .' "${PREVIEW_PLAYBOOK}"
(
    cd "${ROOT_DIR}"
    npx antora generate --clean "${PREVIEW_PLAYBOOK}" --stacktrace
)
