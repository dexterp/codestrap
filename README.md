# CodeStrap

[![Build Status](https://travis-ci.org/dexterp/codestrap.svg?branch=master)](https://travis-ci.org/dexterp/codestrap)
[![Dependency Status](https://gemnasium.com/dexterp/codestrap.png)](https://gemnasium.com/dexterp/codestrap)
[![Inline docs](http://inch-ci.org/github/dexterp/codestrap.svg)](http://inch-ci.org/github/dexterp/codestrap)

CodeStrap is a simple command line project code generator. It provides an easy way to create custom boilerplate for new projects and individual text files, and a very easy way to access that boilerplate.

It is written specifically for ease of use on the command line.

## Quickstart

### 1. Download and install using the package installer

At this stage only Linux and OSX are supported.

[PACKAGES](https://github.com/dexterp/codestrap/releases)
 
### 2. Clone the sample templates to your home directory

```bash
git clone http://github.com/dexterp/codestrap-samples.git $HOME/.codestrap
```

### 3. Add CodeStrap files to your path

```bash
echo 'export PATH=$HOME/.codestrap/bin:$PATH' >> $HOME/.profile
export PATH=$HOME/.codestrap/bin:$PATH
```

### 4. Scan available templates and generate commands (sym links)

```bash
# List templates
ls $HOME/.codestrap/content

# Generate links
strap -g

# List generated commands
ls $HOME/.codestrap/bin
```

### 5. Create files and projects from boilerplate

```bash
# Text file boilerplate
stubrubyscript myscript.rb
stubperlscript myscript.pl
```

```bash
# Project boilerplate
strappuppetmodule mypuppetmodule
straprubygem mygem
```

## Boilerplate Setup

For template setups for both projects and individual files see ...

[BOILERPLATE](https://github.com/dexterp/codestrap/blob/master/BOILERPLATE.md)

## Configuration File

Codestrap uses "Codestrapfile" as a configuration file. For details see.

[CODESTRAPFILE](https://github.com/dexterp/codestrap/blob/master/CODESTRAPFILE.md)

