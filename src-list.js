'use strict'

const fs = require('fs')
//const { name: packageName } = require('./package.json')

module.exports.register = function ({ config }) {

  //const logger = this.getLogger(packageName)
  const { targetName = 'manuals', targetVersion = '' } = config
  //logger.warn('Building sources table sources.adoc')  FIXME: does not log
  this.once('contentAggregated', async ({ contentAggregate }) => {
   const git = requireGit(this)
    let targetFiles
    for (const componentVersionData of contentAggregate) {
      const { name, version, files, nav } = componentVersionData
      // console.log("nav file: " + (nav? nav[0] : 'not found'))
      // FIXME; fails for sources with start_path...
      const referenceFilePath = nav ? nav[0] :  'modules/ROOT/pages/index.adoc'
      if (name === targetName && version === targetVersion) targetFiles = files
      let referenceFile = files.find(({ path }) => path === referenceFilePath)
      referenceFile = referenceFile ? referenceFile : files[0]
      const { gitdir, refhash } = referenceFile.src.origin
      if (gitdir) {
        const commits = await git.log({ fs, gitdir, depth: 1, ref: refhash })
        const lastCommit = commits[0]['commit']
        const lastCommitSummary = {
          name: `${version ? version + '@' : ''}${name}`,
          commit: lastCommit.tree.substr(0, 7),
          subject: lastCommit.message.split(/$/m)[0],
          date: new Date(lastCommit.author.timestamp * 1000),
        }
        componentVersionData.lastCommitSummary = lastCommitSummary
      }
    }
    if (targetFiles) {
      const rows = contentAggregate.map((
        {lastCommitSummary: { name, commit, subject, date }}
      ) => `| ${name} | ${commit} | ${date_str(date)}| ${subject}`).join('\n')
      const contents = Buffer.from(`
= Table of Manual Sources

[cols=3;1;3;7]
|====
| Name | Commit | Date | Subject

${rows}
|====
`.trim()
)
     targetFiles.push({
        path: 'modules/ROOT/pages/sources.adoc',
        contents,
        src: {
          path: 'modules/ROOT/pages/sources.adoc',
          basename: 'sources.adoc',
          stem: 'sources',
          extname: '.adoc',
        }
      })
    }
  })
}

function date_str(date) {
  const year = '20' + ('' + date.getYear()).slice(-2)
  const month = ('0' + date.getMonth()).slice(-2)
  const day = ('0' + date.getDay()).slice(-2)
  const hour = ('0' + date.getHours()).slice(-2)
  const minute  =  ('0' + date.getMinutes()).slice(-2)
  return `${year}-${month}-${day} ${hour}:${minute}`
}

function requireGit ({ module: module_ }) {
  return require(
    require.resolve('isomorphic-git', {
      paths: [require.resolve('@antora/content-aggregator', { paths: module_.paths }) + '/..']
    })
  )
}
