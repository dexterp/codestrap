Given(/^logging tmp directory$/) do
  unless @logging_tmp
    @logging_tmp = Dir.mktmpdir
  end
end

And(/^logging fixtures file "([^"]*)" with:$/) do |yaml, text|
  @logging_fixture_file = File.join(@logging_tmp, yaml)
  file                  = File.open(@logging_fixture_file, 'w')
  file.write(text)
  file.close
  @fixture_hash = YAML.load(text)
  sf_data       = @fixture_hash['codestrapfile']
  sf_path       = File.join(@logging_tmp, 'Codestrapfile')
  file          = File.open(sf_path, 'w')
  file.write(sf_data)
  file.close
  ENV['CODESTRAPFILE'] = sf_path
  @links          = @fixture_hash['links']
  @testtools.path_reset
  @testtools.path_unshift(@links)
end

And(/^logging fixture "([^"]*)"$/) do |command|
  @command     = command
  @fixture_cur = @fixture_hash['commands'][command]
  @output      = @fixture_cur['output']
  @has_output  = @fixture_cur['output?']
  @test        = @fixture_cur['test']
  @stderr      = @fixture_cur['stderr']
end

And(/^logging file linking$/) do
  unless File.exist?('logging/home/logging/codestrap/bin/codestrapcommand')
    FileUtils.ln_s(File.expand_path('logging/home/logging/codestrap/bin/codestrap'), 'logging/home/logging/codestrap/bin/codestrapcommand')
  end
  unless File.exist?('logging/home/logging/codestrap/bin/strapproject')
    FileUtils.ln_s(File.expand_path('logging/home/logging/codestrap/bin/strap'), 'logging/home/logging/codestrap/bin/strapproject')
  end
end

When(/^logging command is executed$/) do
  args = @command.split(/\s+/)
  args << @output if @output
  @logging_capture = Capture::Cli.inline do
    Codestrap::Core.new(args)
  end
end

Then(/^logging output may be generated$/) do
  if @has_output and @has_output.eql?('true')
    expect(File.exist? @output).to be_truthy
  end
end

And(/^logging STDERR contains a message$/) do
  Array(@stderr).each do |err|
    expect(@logging_capture.stderr).to include(err)
  end
end

And(/^logging exits$/) do
  pending
end
