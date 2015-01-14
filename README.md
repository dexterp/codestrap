# CodeStrap #

Project and text file initialisation tool

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

    touch $HOME/.codestrap/objects/contact.yaml

with YAML content

    ---
    name: Masked Avenger
    email: mavenger@the.cloud

Create a template file

    $ touch $HOME/.codestrap/content/rubyscript.erb

with ERB content

    #!/usr/bin/env ruby
    #
    # Author: <%= contact.name %>
    # Email: <%= contact.email %>
    puts "My very cool script"

Manually create a link to the strap binary

    $ ln -s `which strap` $HOME/.codestrap/bin/stubrubyscript

or automatically create the links

    $ strap --generate
    $ ls $HOME/.codestrap/bin/

Add CodeStrap links to $PATH

    $ export PATH=$HOME/.codestrap/bin:$PATH

Lets make some scripts

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

## Contributing

1. Fork it ( https://github.com/dexterp/codestrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
