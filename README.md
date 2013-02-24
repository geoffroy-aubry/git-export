# git-export

## Description
`git-export` is a small tool to easily export a ref from a remote git repository into a local directory.

The result is still a git repository but no requirement is needed. Indeed this tool do:
  - create the target directory if needed
  - depending on status of target directory, choose wisely between `git clone`, `git reset --hard`, `git fetch` or `git checkout`
  - an additionally `git clean -dfx` is executed if `<must-clean>` parameter is setted to 1

This tool is especially convenient to prepare `rsync` to multiple destinations in case of software deployment. 
You specify a branch or a tag and if the local directory is preserved between deployments, then only a fast `git fetch` is executed. 
So in particular only date of updated files are updated and allow an efficient `rsync`.

## Usage
```bash
$ bash /path/to/git-export.sh <url-repo-git> <git-ref-to-export> <local-dir> [<must-clean>]
```

Example:
```bash
$ ./git-export.sh git@github.com:geoffroy-aubry/git-export.git master /tmp/my-export
```

## Copyrights & licensing
Licensed under the GNU Lesser General Public License version 3.
See [LICENSE](https://github.com/geoffroy-aubry/git-export/blob/master/LICENSE) file for details.