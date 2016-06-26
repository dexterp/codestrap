#
# Copyright 2016 Dexter Plameras
#
# All Rights Reserved.
#
require File.absolute_path(File.join(File.dirname(__FILE__),'..','..','lib','codestrap','version'))

name 'codestrap'
maintainer 'Dexter Plameras'
homepage 'https://github.com/dexterp/codestrap'

# Defaults to C:/codestrap on Windows
# and /opt/codestrap on all other platforms
install_dir "#{default_root}/#{name}"

build_version Codestrap::VERSION
build_iteration 1

dependency 'codestrap'

exclude "**/.git"
exclude "**/bundler/git"
