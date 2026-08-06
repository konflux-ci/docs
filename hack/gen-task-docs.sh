#! /bin/bash

set -e

genSrc="$(pwd)/task-docs-gen/src"
dest="$(pwd)/modules/building/pages/task-documentation.adoc"
repo="build-definitions"

mkdir -p "${genSrc}"
pushd "${genSrc}"

rm -rf "${repo}"
git clone --depth 1 "https://github.com/konflux-ci/${repo}.git" "${repo}"

cat > "${dest}" <<'EOF'
= Task documentation
:description: Reference of Tekton tasks from the konflux-ci/build-definitions repository.

// Generated documentation. Please do not edit.
// Run: npm run task-gen

This page lists Tekton tasks defined in
link:https://github.com/konflux-ci/build-definitions/tree/main/task[build-definitions/task].

[cols="2,1,3", options="header"]
|===
| Task | Version | Documentation
EOF

# One row per task: only the latest version that has a README
for task_dir in "${repo}"/task/*/; do
    [ -d "${task_dir}" ] || continue
    name="$(basename "${task_dir}")"

    # Highest semver-like directory that contains README.md
    version="$(
        for ver_dir in "${task_dir}"*/; do
            [ -f "${ver_dir}/README.md" ] || continue
            basename "${ver_dir}"
        done | sort -V | tail -n 1
    )"
    [ -n "${version}" ] || continue

    url="https://github.com/konflux-ci/build-definitions/blob/main/task/${name}/${version}/README.md"
    echo "| \`${name}\` | ${version} | link:${url}[View documentation]" >> "${dest}"
done

echo "|===" >> "${dest}"

popd
echo "Wrote ${dest}"
