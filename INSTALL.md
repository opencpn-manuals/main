## Building the main manual

The manual can be built locally or published on Github Pages

### Updating sources

The site.yml contains all plugin sources from the plugins manual. To create
and update a correct site.yml:

    $ ./make-site-yml

_make_site_yml_ also updates sources.state. To clone and update all sources
to the recorded state:

    $ ./source-state.sh restore


### Publish to Github Pages

Push the current branch to the branch *build*, something like

    $ git push -f origin HEAD:build

The results becomes available at https://github.com/opencpn-manuals/main
after about 3-4  minutes.

### Local builds

Local builds requires Nodejs and Antora installed. See
https://docs.antora.org/antora/2.3/install/install-antora/

With these tools in place, build using

    $ antora site.yml

The resulting website is placed in the directory docs/. Check the
results by pointing the browser to the *docs/index.html* file.
