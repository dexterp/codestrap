# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Provider setup
#
provider = ENV['VAGRANT_DEFAULT_PROVIDER']
case provider
  when 'parallels'
    UBUNTU1404_BOX='parallels/ubuntu-14.04'
    CENTOS72_BOX='parallels/centos-7.2'
  else
    raise "Unknown Vagrant provider #{provider}"
end


# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

rvm_build = <<EOF
sudo -u vagrant -i /bin/bash -l -c "gpg --list-key | grep mpapis@gmail.com 2> /dev/null > /dev/null || curl -sSL https://rvm.io/mpapis.asc | gpg --import -"
sudo -u vagrant -i /bin/bash -l -c "test -f /usr/local/rvm/scripts/rvm 2> /dev/null || \\curl -L https://get.rvm.io | bash -s stable"
sudo -u vagrant -i /bin/bash -l -c "rvm list | grep 2.2.5 2>&1 > /dev/null || rvm install 2.2.5"
sudo -u vagrant -i /bin/bash -l -c "cd /vagrant/omnibus; gem install bundler --no-ri --no-rdoc"
sudo -u vagrant -i /bin/bash -l -c "cd /vagrant/omnibus; bundle install"
test -d /opt/codestrap 2> /dev/null || mkdir -p /opt/codestrap && chown vagrant:vagrant /opt/codestrap
sudo -u vagrant -i /bin/bash -l -c "cd /vagrant/omnibus; omnibus build codestrap"
EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :ubuntu1404 do |conf|
    conf.vm.hostname = 'ubuntu1404'
    conf.vm.box = UBUNTU1404_BOX
    conf.vm.provider provider do |vm|
      vm.linked_clone = true
    end
    conf.vm.provision "shell", inline: <<EOF
# Update distro
test -f /vagrant/.update-apt || touch /vagrant/.update-apt && apt-get update
for i in do curl git build-essential
do
  (dpkg-query -s $i 2>&1) > /dev/null || apt-get install -y $i
done

## install RVM, Ruby, and Bundler
#{rvm_build}
EOF
  end

  config.vm.define :centos72 do |conf|
    conf.vm.hostname = 'centos72'
    conf.vm.box = CENTOS72_BOX
    conf.vm.provider provider do |vm|
      vm.linked_clone = true
    end
    conf.vm.provision "shell", inline: <<EOF
## basics
for i in curl git rpm-build gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel
do
  (rpm -q $i 2>&1) > /dev/null || yum install -y $i
done

## install RVM, Ruby, and Bundler
#{rvm_build}
EOF
  end
end
