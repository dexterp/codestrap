Given(/^client tmp directory$/) do
  unless @client_tmp
    @client_tmp = Dir.mktmpdir
  end
end

And(/^client fixtures file "([^"]*)" with:$/) do |yaml, text|
  @client_fixture_file = File.join(@client_tmp, yaml)
  file                 = File.open(@client_fixture_file, 'w')
  file.write(text)
  file.close
  @fixture_hash = YAML.load(text)
  sf_data       = @fixture_hash['codestrapfile']
  sf_path       = File.join(@client_tmp, 'Codestrapfile')
  file          = File.open(sf_path, 'w')
  file.write(sf_data)
  file.close
  ENV['CODESTRAPFILE'] = sf_path
  @links          = @fixture_hash['links']
  @testtools.path_reset
  @testtools.path_unshift(@links)
end

And(/^client fixture "([^"]+)"$/) do |command|
  @command     = command
  @fixture_cur = @fixture_hash['commands'][command]
  @output      = @fixture_cur['output']
  @test        = @fixture_cur['test']
end

And(/^client generate command is called$/) do
  capture = Capture::Cli.inline do
    args = %w[strap --generate]
    Codestrap::Core.new(args).execute!
  end
  expect(capture.object_exit.status).to eql(0)
end

Then(/^client runs "stub output"$/) do
  if @command =~ /^stub/
    FileUtils.rm_rf(@output) if File.exist?(@output)
    @client_capture = Capture::Cli.inline do
      args = [@command, @output]
      Codestrap::Core.new(args).execute!
    end
  end
end

And(/^client runs "strap output"$/) do
  if @command =~ /^strap/
    FileUtils.rm_rf(@output) if File.exist?(@output)
    args            = [@command, @output]
    @client_capture = Capture::Cli.inline do
      Codestrap::Core.new(args).execute!
    end
  end
end

And(/^client stub exit code is (\d+)$/) do |exit_code|
  if @command =~ /^stub/
    expect(@client_capture.object_exit.status).to eql(exit_code.to_i)
  end
end

And(/^client strap exit code is (\d+)$/) do |exit_code|
  if @command =~ /^stub/
    expect(@client_capture.object_exit.status).to eql(exit_code.to_i)
  end
end

And(/^client stub has the correct interpolated values$/) do
  if @command =~ /^stub/
    Tools::Test.contents(@test) do |content, str, bool|
      case bool
        when 'true'
          expect(content).to include(str)
        when 'false'
          expect(content).not_to include(str)
        else
          fail "Expecting boolean got #{bool.to_s}"
      end
    end
  end
end

And(/^client boilerplate has the correct interpolated values$/) do
  if @command =~ /^strap/
    Tools::Test.contents(@test) do |content, str, bool|
      case bool
        when 'true'
          expect(content).to include(str)
        when 'false'
          expect(content).not_to include(str)
        else
          fail "Expecting boolean got #{bool.to_s}"
      end
    end
  end
end
