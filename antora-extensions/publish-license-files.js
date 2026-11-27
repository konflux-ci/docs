'use strict'

// Publishes the repository's LICENSE and NOTICE files at the root of the
// generated site so that every distributed copy of the documentation
// (production, previews, and downloadable artifacts) includes them, as the
// Apache License 2.0 requires.

const fsp = require('node:fs/promises')
const ospath = require('node:path')

const LICENSE_FILES = ['LICENSE', 'NOTICE']

module.exports.register = function () {
  this.once('beforePublish', async ({ playbook, siteCatalog }) => {
    for (const name of LICENSE_FILES) {
      const contents = await fsp.readFile(ospath.join(playbook.dir, name))
      siteCatalog.addFile({ contents, out: { path: name } })
    }
  })
}
