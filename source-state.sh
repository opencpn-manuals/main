#!/bin/bash

#
# Some pidgin git submodules mockup. Allows all included plugin
# directories to be represented by their url and commit.
#
# Arguments: an operation, mandatory, one of:
#
#   - restore: fetches and checkout all repos listed in statefile
#   - save: Save state of all plugin repos in statefile
#   - update: Update all plugin repos to latest version (does not save!).
#
# Files:
#   sources.state: directory, url and commit for plugin sources.
#


here=$(readlink -fn $(dirname $0))
statefile="$here/sources.state"
test -d $here/sources || mkdir $here/sources

cleanup_clone() {
    if test -f .git/info/sparse-checkout; then return; fi
    for f in *; do
        case $f in
            manual|antora.yml|modules) true ;;
            *) rm -rf $f
        esac
    done
}

git_clone() {
    vers=$(git --version)
    if [[ "$vers" == *2.[345][0-9].* ]]; then   # > 2.30
        git clone --depth 1 --filter=blob:none --sparse $1
        cd $2
        git sparse-checkout set manual
    else
        git clone --depth 2 $1
        cd $2
        cleanup_clone
    fi
    cd ..
}

cd $here/sources
git config --global advice.detachedHead false
case "$1" in
    restore) 
        while true; do
            read dir url commit || exit 0
            test -d $dir || git_clone $url $dir
            cd $dir
            git fetch origin $commit
            git checkout -q FETCH_HEAD
            cd ..
        done < $statefile
        ;;

    update)
        for dir in $(find . -maxdepth 1 -mindepth 1 -type d); do
            cd $dir
            echo -n "$dir: "
            git remote update origin
            head=$(git rev-parse refs/remotes/origin/HEAD)
            git checkout $head
            cleanup_clone
            cd ..
        done
        ;;

    save)
        rm -f $statefile
        for dir in $(find . -maxdepth 1 -mindepth 1 -type d); do
            url=$(git -C $dir config remote.origin.url)
            echo $dir $url $(git -C $dir rev-parse HEAD) >> $statefile
        done
        ;;

    *) echo 'Usage: $0: <save | restore | update>'
        ;;
esac
