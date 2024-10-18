#!/bin/bash
# Rebuild both asciidocs tekton indices in place

set -e -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "☝️ First, render index for the build-definitions rrepo"
"$SCRIPTDIR/generate-tekton-index.sh" https://github.com/konflux-ci/build-definitions main task
cat << EOF > docs/modules/ROOT/pages/tasks/build.adoc
= Build pipeline tasks

These tasks, defined in the https://github.com/konflux-ci/build-definitions[build-definitions repo] are tasks provided by and supported as a part of the {ProductName} platform.
You can use references to these tasks when xref:/how-tos/configuring/customizing-the-build.adoc#configuring-timeouts[customizing your build pipeline].

EOF
cat "$SCRIPTDIR/../tasks.adoc" >> docs/modules/ROOT/pages/tasks/build.adoc

echo "✌️ Second, render index for therelease-service catalog"
"$SCRIPTDIR/generate-tekton-index.sh" https://github.com/konflux-ci/release-service-catalog production tasks
cat << EOF > docs/modules/ROOT/pages/tasks/release.adoc
= Release pipeline tasks

These tasks, defined in the https://github.com/konflux-ci/release-service-catalog[release-service catalog repo] are tasks provided by and supported as a part of the {ProductName} platform.
You can combine references to these tasks in different ways when creating new release pipelines.

EOF
cat "$SCRIPTDIR/../tasks.adoc" >> docs/modules/ROOT/pages/tasks/release.adoc

echo "🧹 Cleaning up."
rm "$SCRIPTDIR/../tasks.adoc"

echo "✅ Done."
echo

git status
