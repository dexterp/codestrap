# CodeStrap #

---

[![Build Status](https://travis-ci.org/dexterp/codestrap.svg?branch=master)](https://travis-ci.org/dexterp/codestrap)
[![Dependency Status](https://gemnasium.com/dexterp/codestrap.png)](https://gemnasium.com/dexterp/codestrap)
[![Inline docs](http://inch-ci.org/github/dexterp/codestrap.svg)](http://inch-ci.org/github/dexterp/codestrap)

CodeStrap is a code generator for the generation of project and individual text file boilerplate. Its written
specifically with command line usage in mind.

## Command line usage pattern ##

There are two starting **command parts**...

 * **strap**...

```ruby
strap*project* $NEW_DIRECTORY
# E.G.
strappuppetmodule apache2
straprubygem codestrap
strapproject mynewproject
```

 * **stub**...

```ruby
stub*template* $NEW_FILE
# E.G.
stubrubyscript /usr/local/bin/myscript.rb
stubbashscript /usr/local/bin/myscript.sh
stubinitscript /etc/rc.d/init.d/startdaemon
```

Every **strapproject** and **stubtemplate** is a command and a symlink to the **strap** command. Command symlinks
are stored by default in the $HOME/.codestrap/bin directory. Each command renders a corresponding project or
file template.

```
# Code generator for a project
$HOME/.codestrap/bin/straprubygem
# Corresponding project boilerplate
$HOME/.codestrap/content/rubygem/

# Code generator for a text file
$HOME/.codestrap/bin/stubrubyscript
# Corresponding file template
$HOME/.codestrap/content/rubyscript.erb
```

By adding the *CodeStrap* bin directory to the default $PATH, all project and template boilerplate are are available
anywhere on the command line.

```bash
$ export PATH=$HOME/.codestrap/bin
$ strappuppetmodule ~/workspace/apache
$ stubrubyscript /usr/local/bin/newscript.rb
```

## Installation ##

Add this line to your application's Gemfile:

```ruby
gem 'codestrap'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install codestrap
```

Check its installed

```
strap --version
```

## Usage ##

### Text file ###

Create your directory structure

```
mkdir $HOME/.codestrap
mkdir $HOME/.codestrap/bin
mkdir $HOME/.codestrap/objects
mkdir $HOME/.codestrap/content
```

Create a basic object

```
touch $HOME/.codestrap/objects/contact.yaml
```

with YAML content

```yaml
---
name: Masked Avenger
email: mavenger@the.cloud
```

Create a template file

```
$ touch $HOME/.codestrap/content/rubyscript.erb
```

with ERB content

```ruby
#!/usr/bin/env ruby
#
# Author: <%= contact.name %>
# Email: <%= contact.email %>
puts "My very cool script"
```

Manually create a link to the strap binary

```
$ ln -s `which strap` $HOME/.codestrap/bin/stubrubyscript
```

or automatically create the links

```
$ strap --generate
$ ls $HOME/.codestrap/bin/
```

Add CodeStrap links to $PATH

```
$ export PATH=$HOME/.codestrap/bin:$PATH
```

generate scripts

```ruby
$ stubrubyscript /usr/local/bin/helloworld
$ chmod 755 /usr/local/bin/helloworld
$ helloworld
My very cool script

$ cat /usr/local/bin/helloworld
#!/usr/bin/env ruby
#
# Author: Masked Avenger
# Email: mavenger99@the.cloud
puts "My very cool script"
```

## Contributing

1. Fork it ( https://github.com/dexterp/codestrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
