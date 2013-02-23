#!/usr/bin/env bash

##
# git-export.sh is a small tool to easily export a ref from a remote git repository into a local directory.
#
# The result is still a git repository but no requirement is needed. Indeed this tool do:
#     – create the target directory if needed
#     – depending on status of target directory, choose wisely between git clone, git reset --hard, git fetch or git checkout
#     – an additionally git clean -dfx is executed if <must-clean> parameter is setted to 1
#
# This tool is especially convenient to prepare rsync to multiple destinations in case of software deployment. You specify a branch or a tag and if the local directory is preserved between deployments, then only a fast git fetch is executed. So in particular only date of updated files are updated and allow an efficient rsync.
#
# Usage : bash /path/to/git-export.sh <url-repo-git> <git-ref-to-export> <local-dir> [<must-clean>]
# Example :
#   bash ./git-export.sh \
#       git@indefero.hi-media-techno.com:advertising-comtrack-tracker.git \
#       v2.0.3 \
#       /tmp/tracker_export
#
# @author Geoffroy AUBRY <geoffroy.aubry@free.fr>
#



repository="$1"
reponame='origin'
ref="$2"
srcdir="$3"
mustclean="$4"

if [ -z "$repository" ] || [ -z "$ref" ] || [ -z "$srcdir" ]; then
    echo 'Missing parameters!' >&2
    exit 1
fi

mkdir -p "$srcdir" && cd "$srcdir" || exit $?

current_repository="$(git remote -v 2>/dev/null | grep -E ^$reponame | head -n 1 | sed 's/^'"$reponame"'\s*//' | sed 's/\s*([^)]*)$//')"
if [ "$current_repository" = "$repository" ]; then
    if [ `git status --porcelain --ignore-submodules=all | wc -l` -ne 0 ]; then
        echo "Git: reset local repository"
        git reset --hard 1>/dev/null || exit $?
    fi
    echo "Git: fetch '$reponame' repository"
    git fetch --quiet --prune $reponame 1>/dev/null || exit $?
else
    echo "Git: clone '$reponame'"
    rm -rf "$srcdir" && mkdir -p "$srcdir" && cd "$srcdir" && \
    git clone --quiet --origin "$reponame" "$repository" . 1>/dev/null || exit $?
fi

if git branch -r --no-color | grep -q "$reponame/$ref"; then
    if git branch --no-color | grep -q "$ref"; then
        echo "Git: checkout and update local branch '$ref'"
        git checkout --quiet "$ref" 1>/dev/null && git pull --quiet "$reponame" "$ref" 1>/dev/null || exit $?
    else
        echo "Git: checkout remote branch '$reponame/$ref'"
        git checkout --quiet -fb "$ref" "$reponame/$ref" 1>/dev/null || exit $?
    fi
elif git tag | grep -q "$ref"; then
    echo "Git: checkout tag '$ref'..."
    git checkout --quiet -f "refs/tags/$ref" 1>/dev/null || exit $?
else
    echo "Git: branch or tag '$ref' not found!" >&2 && exit 1
fi

if [ "$mustclean" = '1' ]; then
    echo 'Cleans the working tree...'
    git clean -dfx --quiet 1>/dev/null || exit $?
fi

