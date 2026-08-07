#! /bin/bash

set -e

genSrc="$(pwd)/task-docs-gen/src"
dest="$(pwd)/modules/building/pages/task-documentation.adoc"
repo="build-pipeline-tasks"

mkdir -p "${genSrc}"
pushd "${genSrc}"

rm -rf "${repo}"
git clone --depth 1 "https://github.com/konflux-ci/${repo}.git" "${repo}"

cat > "${dest}" <<'EOF'
= Task documentation
:description: Reference of Tekton tasks from the konflux-ci/build-pipeline-tasks repository.

// Generated documentation. Please do not edit.
// Run: npm run task-gen

This page lists Tekton tasks defined in
link:https://github.com/konflux-ci/build-pipeline-tasks/tree/main/task[build-pipeline-tasks/task].

[cols="2,3", options="header"]
|===
| Task | Documentation
EOF

# One row per task that has a README (layout: task/<name>/README.md)
for readme in "${repo}"/task/*/README.md; do
    [ -f "${readme}" ] || continue

    name="$(basename "$(dirname "${readme}")")"
    url="https://github.com/konflux-ci/build-pipeline-tasks/blob/main/task/${name}/README.md"
    echo "| \`${name}\` | link:${url}[View documentation]" >> "${dest}"
done

echo "|===" >> "${dest}"

popd
echo "Wrote ${dest}"
