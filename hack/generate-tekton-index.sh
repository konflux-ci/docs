#!/bin/bash
# Build an asciidocs index of all tasks defined in this repo.

set -e -o pipefail

VCS_URL="$1"
BRANCH="$2"
SUBDIR="$3"

if [ -z "${VCS_URL+x}" ] || [ -z "${BRANCH+x}" ] || [ -z "${SUBDIR+x}" ]; then
    echo "Usage::"
    echo "  ./hack/generate-tekton-index.sh https://github.com/konflux-ci/build-definitions main task"
    exit 1
fi

# local dev build script
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WORKDIR=$(mktemp -d --suffix "-$(basename "${BASH_SOURCE[0]}" .sh)")
NOW=$(date +%Y-%m-%d)

git clone -b "$BRANCH" "$VCS_URL" "$WORKDIR/repo"

cat << EOF > "$WORKDIR/tasks.adoc"
EOF

# Build tasks
(
cd "$WORKDIR/repo"
find "$SUBDIR/"*/ "$SUBDIR/"*/*/ -maxdepth 0 -type d | awk -F '/' '{ print $0, $2, $3 }' | \
while read -r task_dir task_name task_version
do
    if [[ "${task_dir}" == */tests/ ]]; then
        continue
    fi
    if [ ! -f "${task_dir}/${task_name}.yaml" ]; then
        echo "${task_dir}/${task_name}.yaml"
        echo "Skipping ${task_name}.yaml. kustomize rendering not supported yet"
        continue
    fi

    expiration=$(yq '.metadata.annotations."build.appstudio.redhat.com/expires-on"' "$task_dir/$task_name.yaml")
    if [ "$expiration" != "null" ]; then
        if [ "${expiration%T*}" > "${NOW}" ]; then
            continue
        fi
    fi

    if [ "${task_version}" == "" ]; then
        task_version=$(yq '.metadata.labels."app.kubernetes.io/version" // "undefined"' "$task_dir/$task_name.yaml")
    fi

    url="${VCS_URL}/tree/${BRANCH}/${task_dir}"

    echo >> "$WORKDIR/tasks.adoc"
    echo -n "[[$task_name]]$task_name ($task_version):: " >> "$WORKDIR/tasks.adoc"

    description=$(yq '.spec.description | split("\n") | .[0]' "$task_dir/$task_name.yaml")
    echo -n "$description " >> "$WORKDIR/tasks.adoc"

    echo -n "See also:" >> "$WORKDIR/tasks.adoc"
    for document in README.md USAGE.md MIGRATION.md TROUBLESHOOTING.md; do
        if [ -f "${task_dir}/${document}" ]; then
            echo -n " ${url}${document}[${document}]" >> "$WORKDIR/tasks.adoc"
        fi
    done

    echo >> "$WORKDIR/tasks.adoc"
done
)

echo "$WORKDIR/tasks.adoc"
