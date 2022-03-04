#!/bin/bash
#
# Build an website using Antora and deploy to Github Pages
#
# Configuration:
#     Needs GITHUB_TOKEN in environment, usually using something like
#         env:
#           GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
#
set -xe

# Some hard-coded assumptions:
readonly PLAYBOOK='site.yml'       # The Antora playbook
readonly SITE_DIR='docs'           # Antora output directory
readonly GP_BRANCH='gh-pages'      # Branch used as input by Github Pages

# Install npm and antora
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
npm -v
npm i

# Build site and block github's default jekyll formatting
npm run build
touch $SITE_DIR/.nojekyll

# Set up a git environment in $SITE_DIR
author_email=$(git log -1 --pretty=format:"%ae")
cd $SITE_DIR
git init -b pages
git remote add origin \
    https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY
git config --local user.email "$author_email"
git config --local user.name "$GITHUB_ACTOR"

# Commit changes and push to $GP_BRANCH
git add --all .
git commit -q -m "[CI] Updating $GP_BRANCH branch from ${GITHUB_SHA:0:8}"
git push -f origin pages:$GP_BRANCH
