#! /bin/bash

set -e

repo_root="$(pwd)"
dest="${repo_root}/modules/building/pages/task-documentation.adoc"
repo="container-build-catalog"
genSrc="$(mktemp -d /tmp/container-build-catalog.XXXXXX)"
trap 'rm -rf "${genSrc}"' EXIT

pushd "${genSrc}"

git clone --depth 1 "https://github.com/konflux-ci/${repo}.git" "${repo}"

cat > "${dest}" <<'EOF'
= Task documentation
:description: Reference of Tekton tasks from the konflux-ci/container-build-catalog repository.

// Generated documentation. Please do not edit.
// Run: npm run gen-build-tasks-docs

This page lists Tekton tasks defined in
link:https://github.com/konflux-ci/container-build-catalog/tree/main/task[container-build-catalog/task].

[cols="2,3", options="header"]
|===
| Task | Documentation
EOF

# One row per task that has a README (layout: task/<name>/README.md)
for readme in "${repo}"/task/*/README.md; do
    [ -f "${readme}" ] || continue

    name="$(basename "$(dirname "${readme}")")"
    url="https://github.com/konflux-ci/container-build-catalog/blob/main/task/${name}/README.md"
    echo "| \`${name}\` | link:${url}[Task README]" >> "${dest}"
done

echo "|===" >> "${dest}"

popd
echo "Wrote ${dest}"
