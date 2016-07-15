Given(/^a missing ~\/\.codestrap directory$/) do
  FileUtils.rm_rf('init_home_dir') if File.exists?('init_home_dir')
  Dir.mkdir('init_home_dir')
end

When(/^the initialisation "strap \-g" is run$/) do
  override = ENV
  override['HOME'] = 'init_home_dir'
  @init_home_output = Capture::Cli.inline do
    args = %w(strap -g)
    obj = Codestrap::Core.new(args)
    obj.env = override
    obj.execute!
  end
end

Then(/^the ~\/\.codestrap\/bin directory is created$/) do
  bin = File.join(%W[init_home_dir .codestrap bin])
  expect(File.directory? bin).to be_truthy
end

And(/^the ~\/\.codestrap\/content directory is created$/) do
  content = File.join(%W[init_home_dir .codestrap content])
  expect(File.directory? content).to be_truthy
end

And(/^the ~\/\.codestrap\/objects directory is created$/) do
  objects = File.join(%W[init_home_dir .codestrap objects])
  expect(File.directory? objects).to be_truthy
end

And(/^the ~\/\.codestrap\/Codestrail file is created$/) do
  codestrapfile = File.join(%W[init_home_dir .codestrap Codestrapfile])
  expect(File.file? codestrapfile).to be_truthy
end