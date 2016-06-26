# Configuration

The default configuration file for Codestrap is located at

```
$HOME/.codestrap/Codestrapfile
```

This can be overriden using the $CODESTRAPFILE environment variable 

```bash
export CODESTRAPFILE='/usr/local/codestrap/Codestrapfile'
```

Available settings

```ruby
Codestrapfile.config do |conf|
  # Base directory or list of base directories that contain "object" and "content" sub directories
  # Defaults to $HOME/.codestrap
  #conf.local.base   = [ '/home/user/.codestrap', '/usr/local/codestrap' ]
  #conf.local.base = '/home/user/.codestrap'
  
  # Ignore paths or list of paths to ignore
  #conf.local.ignore = [ '.git', '.svn' ]
  #conf.local.ignore = '.git'
end
```
