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
