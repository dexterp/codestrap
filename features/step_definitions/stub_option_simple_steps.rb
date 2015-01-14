When(/^the command "(strap)" with option "([^"]+)" is executed/) do |cmd, opt|
  @testtools.path_reset
  @testtools.path_unshift(BINDIR)
  @cap_simple = Capture::Cli.inline do
    args = [cmd, opt]
    Codestrap::Core.new(args).execute!
  end
end

Then(/^the option output is greater then (\d+) bytes$/) do |size|
  expect(@cap_simple.stdout.length).to be > size.to_i
end

And(/^the option option exit status should be (\d+)$/) do |status|
  expect(@cap_simple.object_exit.status.to_i).to eq(status.to_i)
end

When(/^the version is requested through the "(.*?)" option \-\-version is provided$/) do |cmd|
  @cap_version = Capture::Cli.new(true, false).inline do
    args = [cmd, '--version']
    Codestrap::Core.new(args).execute!
  end
end

Then(/^the version option exit status is (\d+)$/) do |status|
  expect(@cap_version.object_exit.status).to eq(status.to_i)
end

And(/^a version number is outputed$/) do
  expect(@cap_version.stdout.chomp).to eql(Codestrap::VERSION)
end
