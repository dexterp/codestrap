ROOT          = File.dirname(File.expand_path(__FILE__))
FEATURES_PATH = File.join(ROOT, 'features')
LIB_PATH      = File.join(ROOT, 'lib')
TMP_PATH      = File.join(ROOT, 'tmp')
TMP_FILES     = Rake::FileList.new(File.join(ROOT, 'tmp','*'))
PACKAGES      = Rake::FileList.new(File.join(ROOT, 'pkg', '*'))
DOCS          = Rake::FileList.new(File.join(ROOT, 'doc', '*'))
$LOAD_PATH.unshift(LIB_PATH)
require 'codestrap'
require 'codestrap/version'
require 'bundler/gem_tasks'
require 'cucumber'
require 'cucumber/rake/task'
require 'rake'
require 'yard'
require 'dotenv'

def getinput(prompt)
  print prompt
  STDIN.gets.chomp
end


Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "#{FEATURES_PATH} -r #{FEATURES_PATH}/step_definitions -r #{FEATURES_PATH}/support --format pretty"
end

YARD::Rake::YardocTask.new do |t|
  t.files   = %w[ lib/**/*.rb ]
end

desc 'Clean files'
task :clean do
  clean = []
  clean += TMP_FILES
  clean += PACKAGES
  clean += DOCS
  clean.each do |file|
    rm_rf file
  end
end

desc 'Uninstall'
task :uninstall do
  sh 'gem uninstall codestrap -x'
end

desc 'Reinstall'
task :reinstall do
  Rake::Task['uninstall'].invoke
  Rake::Task['install'].invoke
end

desc 'Package using omnibus'
task :package do
  Rake::Task['build'].invoke
  sh 'omnibus build codestrap'
end

desc 'Environment variables setup in ".env" file'
task :env do
  dotenv_file = File.join(ROOT,'.env')

  unless File.exist?(dotenv_file)
    env = {}
    puts ".env file is missing. Setting up\n"
    provider = getinput('Which vagrant provider do you use 1. "Virtualbox", 2. "Parallels". [1 or 2]: ')
    case provider
      when 1.to_s
        env['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
      when 2.to_s
        env['VAGRANT_DEFAULT_PROVIDER'] = 'parallels'
      else
        raise 'Unknown provider type'
    end

    File.open(dotenv_file,'w') do |fh|
      env.each_pair do |key,value|
        fh.write "#{key}=#{value}\n"
      end
      fh.close
    end
  end

  Dotenv.load()
end
