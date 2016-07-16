require File.absolute_path(File.join(File.dirname(__FILE__),'..','..','..','lib','codestrap','version'))

name 'codestrap'
default_version Codestrap::VERSION

dependency 'ruby'
dependency 'rubygems'

build do
  pkg = File.absolute_path(File.join(File.dirname(__FILE__),'..','..','..','pkg',"codestrap-#{version}.gem"))
  gem "install #{pkg} -n #{install_dir}/bin --no-rdoc --no-ri -v #{version}"
  delete "/opt/#{name}/embedded/docs"
  delete "/opt/#{name}/embedded/share/man"
  delete "/opt/#{name}/embedded/share/doc"
  delete "/opt/#{name}/embedded/ssl/man"
  delete "/opt/#{name}/embedded/info"
  delete "/opt/#{name}/bin/upstrap"
  delete "/opt/#{name}/bin/rackup"
  delete "/opt/#{name}/bin/tilt"
end
