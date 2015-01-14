# Feature: Supports script object creation
Given(/^a script directory "([^"]*)"$/) do |dir|
  @dir = dir
end

And(/^a script "([^"]*)"$/) do |script|
  @script = script
end

When(/^a script run to create an object$/) do
  @output = `#{File.join(@curdir, @dir, @script)}`
  @status = $?
end

Then(/^the objects JSON syntax is valid$/) do
  expect(JSON.is_json?(@output)).to be true
end

And(/^a object is created$/) do
  object = nil
  Dir.chdir @curdir do
    object       = Codestrap::Object::Factory.new
    object.dirs = 'test/fixtures/objects'
  end
  expect(object.nil?).to be false
end
