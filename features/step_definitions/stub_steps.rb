Given(/^a stub tmp directory$/) do
  unless @codestrap_tmp
    @codestrap_tmp = Dir.mktmpdir
  end
end

And(/^a stub fixtures file "([^"]*)" with:$/) do |yaml, text|
  @codestrap_fixtures = File.join(@codestrap_tmp, yaml)
  file                = File.open(@codestrap_fixtures, 'w')
  file.write(text)
  file.close
  @fixture_hash = YAML.load(text)
end

And(/^a stub fixture "([^"]+)"$/) do |command|
  @command     = command
  @fixture_cur = @fixture_hash[@command]
  @links       = @fixture_cur['links']
  @clear       = @fixture_cur['clear']
  @output      = @fixture_cur['output']
  @test        = @fixture_cur['test']
  sf_content   = @fixture_cur['codestrapfile']
  sf_path      = File.join(@codestrap_tmp, 'Codestrapfile')
  sf_file      = File.open(sf_path, 'w')
  sf_file.write sf_content
  sf_file.close
  ENV['CODESTRAPFILE']=sf_path
end

And(/^stub env variable for PATH$/) do
  @testtools.path_reset
  @testtools.path_unshift(@links)
end

#And(/^codestrap env variable CODESTRAP_CONF="([^"]*)"$/) do |codestrapconf|
#  ENV['CODESTRAP_CONF'] = codestrapconf
#end
#
#And(/^codestrap env variable CODESTRAP_ETC="([^"]+)"$/) do |codestrapetc|
#  ENV['CODESTRAP_ETC'] = @codestrapetc = codestrapetc
#end
#
#And(/^codestrap env variable HOME="(codestrap\/contact\/home\/user)"$/) do |home|
#  ENV['HOME'] = @codestraphome = home
#end
#
#And(/^a interpolation template named "([^"]*)"$/) do |templatefile|
#  templatefile =~ /(.erb)$/
#  suffix    = $1 if $1
#  @basename = File.basename(templatefile)
#  FileUtils.install File.join(FIXTURES, templatefile), File.join(@codestrapetc, @basename)
#  if suffix
#    @cmd = 'codestrap' + File.basename(templatefile, suffix)
#  else
#    @cmd = 'codestrap' + File.basename(templatefile)
#  end
#end

When(/^generate$/) do
  @cap_generate_interpolate_links = Capture::Cli.inline do
    args = %w(strap --generate)
    Codestrap::Core.new(args).execute!
  end
end

And(/^clear previous files$/) do
  if @clear and File.exist? @output
    File.unlink @output
  end
end

And(/^template is run with output$/) do
  @cap_interpolate_contact_output = Capture::Cli.inline do
    args = [@command, @output]
    Codestrap::Core.new(args).execute!
  end
end

Then(/^contains interpolated values$/) do
  @test.each_pair do |str, bool|
    case bool
      when true
        expect(File.read(@output)).to include(str)
      when false
        expect(File.read(@output)).not_to include(str)
      else
        fail 'Invalid check'
    end
  end
end

And(/^the exit status is (\d+)$/) do |status|
  expect(@cap_interpolate_contact_output.object_exit.status.to_i).to eq(status.to_i)
end
