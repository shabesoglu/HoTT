#!/usr/bin/env bash

PS4='$ '
set -x

sudo apt-get update -qq
sudo apt-get install -q ghc cabal-install graphviz
cabal update
cabal install graphviz text
