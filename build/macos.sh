#!/bin/sh

set -ue

brew install squashfs
curl -sL https://dl.bintray.com/kontena/ruby-packer/0.5.0-dev/rubyc-darwin-amd64.gz | gunzip > /usr/local/bin/rubyc
chmod +x /usr/local/bin/rubyc
rubyc -o superbot superbot
./superbot version

# ship to github
curl -sL https://github.com/aktau/github-release/releases/download/v0.7.2/darwin-amd64-github-release.tar.bz2 | tar -xjO > /usr/local/bin/github-release
chmod +x /usr/local/bin/github-release
/usr/local/bin/github-release upload \
    --user superbothq \
    --repo superbot \
    --tag $TRAVIS_TAG \
    --name "superbot-darwin-amd64" \
    --file ./superbot
