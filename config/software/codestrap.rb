require File.absolute_path(File.join(File.dirname(__FILE__),'..','..','lib','codestrap','version'))

name 'codestrap'
default_version Codestrap::VERSION

dependency 'ruby'
dependency 'rubygems'

build do
  pkg = File.absolute_path(File.join(File.dirname(__FILE__),'..','..','pkg',"codestrap-#{version}.gem"))
  gem "install #{pkg} -n #{install_dir}/bin --no-rdoc --no-ri -v #{version}"
  command "rm -rf /opt/#{name}/embedded/docs"
  command "rm -rf /opt/#{name}/embedded/share/man"
  command "rm -rf /opt/#{name}/embedded/share/doc"
  command "rm -rf /opt/#{name}/embedded/ssl/man"
  command "rm -rf /opt/#{name}/embedded/info"
  command "rm -rf /opt/#{name}/bin/upstrap"
  command "rm -rf /opt/#{name}/bin/rackup"
  command "rm -rf /opt/#{name}/bin/tilt"
end
