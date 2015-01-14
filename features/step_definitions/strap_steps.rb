Given(/^a boilerplate path directory "([^"]*)"$/) do |path|
  @testtools.path_reset
  @testtools.path_unshift(path)
end

And(/^a boilerplate fixture (\d+)$/) do |num|
  @fixture_idx = num.to_i
end

And(/^a boilerplate tmp directory$/) do
  unless @strap_tmpdir
    @strap_tmpdir = Dir.mktmpdir
  end
end

And(/^a boilerplate codestrapfile named "([^"]*)" with:$/) do |codestrapfile, text|
  codestrapfile_path = File.join(@strap_tmpdir, codestrapfile)
  unless File.exist? codestrapfile_path
    file = File.new(codestrapfile_path, 'w')
    file.write(text)
    file.close
  end
  ENV['CODESTRAPFILE']=codestrapfile_path
end

And(/^a boilerplate fixtures file named "([^"]*)" with:$/) do |json, text|
  @fixtures = File.join(@strap_tmpdir, json)
  unless File.exist? @fixtures
    file = File.open(@fixtures, 'w')
    file.write(text)
    file.close
  end
  @fixture_hash = YAML.load(File.read(@fixtures))[@fixture_idx]
  @clear        = @fixture_hash['clear'] == 'true'
  @command      = @fixture_hash['command']
  @output       = @fixture_hash['output']
end

When(/^boilerplate generate command is executed$/) do
  capture = Capture::Cli.inline do
    args = %w(strap --generate)
    Codestrap::Core.new(args).execute!
  end
  expect(capture.object_exit.status).to eql(0)
end

And(/^boilerplate command is run$/) do
  if @clear
    FileUtils.rm_rf @output
  end
  @capture = Capture::Cli.inline do
    args = [@command, @output]
    Codestrap::Core.new(args).execute!
  end
  expect(File.directory?(@output)).to be_truthy
end

Then(/^boilerplate contains interpolated values$/) do
  Tools::Test.contents(@fixture_hash['test']) do |content, str, bool|
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
