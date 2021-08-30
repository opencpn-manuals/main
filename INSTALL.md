## Building the main manual

The manual can be built locally or published on Github Pages

### Publish to Github Pages

Push the current branch to the branch *build*, something like

    $ git push -f origin HEAD:build

The results becomes available at https://github.com/opencpn-manuals/main
after about 3-4  minutes.

### Local builds

Local builds requires Nodejs and Antora installed. See
https://docs.antora.org/antora/2.3/install/install-antora/

First create a usable site.yml and also update sources.state to match the
list of plugins used in opencpn-manuals/plugins.

    $ ./make-site-yml

The generated site.yml and sources.state can be committed. Then populate
the clones of included projects using

    $ ./source-state.sh restore

With antora installed build using:

    $ antora site.yml

The resulting website is placed in the directory docs/. Check the
results by pointing the browser to the *docs/index.html* file.
