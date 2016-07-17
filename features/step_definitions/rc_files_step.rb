Given(/^a known "([^"]*)"$/) do |shell|
  @shell = shell
end

And(/^a "([^"]*)" directory$/) do |dir|
  @fake_home = File.join(ROOT,'tmp',dir)
  FileUtils.rm_rf(@fake_home) if File.exist?(@fake_home)
  FileUtils.mkpath(@fake_home)
end

And(/^with a ~\/"([^"]*)"$/) do |rcfile|
  src_file = File.absolute_path(File.join(FIXTURE_ROOT,'rc_files',rcfile))
  @rcfile = File.absolute_path(File.join(@fake_home,rcfile))
  FileUtils.copy(src_file, @rcfile) if File.exist? src_file
end

When(/^the initialisation "strap \-g" is run for rc_files more then once$/) do
  env = ENV.to_hash
  env['SHELL'] = @shell
  env['HOME'] = @fake_home
  2.times do
    Capture::Cli.inline do
      args = %w(strap -g)
      obj = Codestrap::Core.new(args)
      obj.env = env
      obj.execute!
    end
  end
end

Then(/^a path entry should be added. Once only$/) do
  cnt = 0
  File.open(@rcfile).each_line do |line|
    cnt += 1 if line =~ %r{export PATH=\$PATH:\$HOME/\.codestrap/bin}
  end
  expect(cnt == 1).to be_truthy
end