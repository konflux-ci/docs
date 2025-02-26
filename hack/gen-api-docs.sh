#! /bin/bash

set -e


genRoot="$(pwd)/api-gen/src"
config="$(pwd)/api-gen/crd-ref-docs.yaml"
destRoot="$(pwd)/docs/modules/ROOT/pages/reference/kube-apis"

function gen_ref_docs {
    # First argument is the repository name in the konflux-ci GitHub org.
    # It also serves as the directory where code will be cloned into.
    local repo="${1}"
    if [ -d "${repo}" ]; then
        rm -rf "${repo}"
    fi

    local host="https://github.com/konflux-ci/${repo}.git"

    # Optional second argument if the source code is not hosted in the konflux-ci GitHub org.
    if [ -n "${2}" ]; then
        host="${2}"
    fi

    git clone --depth 1 "${host}" "${repo}"

    crd-ref-docs --config "${config}" \
      --renderer asciidoctor \
      --source-path "${repo}/api" \
      --output-path "${destRoot}/${repo}.adoc"
}


mkdir -p "${genRoot}"

pushd "${genRoot}"

gen_ref_docs "application-api"
gen_ref_docs "enterprise-contract" "https://github.com/enterprise-contract/enterprise-contract-controller.git"
gen_ref_docs "image-controller"
gen_ref_docs "integration-service"
gen_ref_docs "release-service"

popd
