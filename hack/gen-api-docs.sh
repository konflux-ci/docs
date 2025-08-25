#! /bin/bash

set -e


genRoot="$(pwd)/api-gen"
genSrc="${genRoot}/src"
config="$(pwd)/api-gen/crd-ref-docs.yaml"
destRoot="$(pwd)/modules/reference/pages/kube-apis"

function gen_ref_docs {
    # First argument is the repository name in the konflux-ci GitHub org.
    # It also serves as the directory where code will be cloned into.
    local repo="${1}"
    if [ -d "${repo}" ]; then
        rm -rf "${repo}"
    fi

    # Second argument is the title
    local title="${2}"
    if [ -z "${title}" ]; then
        title="${repo}"
    fi

    local host="https://github.com/konflux-ci/${repo}.git"

    # Optional thrid argument if the source code is not hosted in the konflux-ci GitHub org.
    if [ -n "${3}" ]; then
        host="${3}"
    fi

    git clone --depth 1 "${host}" "${repo}"

    KONFLUX_TITLE="${title}" crd-ref-docs --config "${config}" \
      --renderer asciidoctor \
      --source-path "${repo}/api" \
      --output-path "${destRoot}/${repo}.adoc" \
      --templates-dir="${genRoot}/templates"
}


mkdir -p "${genSrc}"

pushd "${genSrc}"

gen_ref_docs "application-api" "Application"
gen_ref_docs "conforma" "Conforma" "https://github.com/enterprise-contract/enterprise-contract-controller.git"
gen_ref_docs "image-controller" "Image"
gen_ref_docs "integration-service" "Integration Test"
gen_ref_docs "release-service" "Release"
gen_ref_docs "mintmaker" "DependencyUpdateCheck"
gen_ref_docs "project-controller" "Project Controller"

popd
