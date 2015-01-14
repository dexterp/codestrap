#Given(/^server environment variables "([^"]*)"$/) do |etc|
#  ENV['CODESTRAP_ETC'] = @etc = etc
#end

Given(/^server tmp directory$/) do
  unless @server_tmp
    @server_tmp = Dir.mktmpdir
  end
end

And(/^server fixtures file "([^"]*)" with:$/) do |yaml, text|
  @server_fixture_file = File.join(@server_tmp, yaml)
  file                 = File.open(@server_fixture_file, 'w')
  file.write(text)
  file.close
  @fixture_hash = YAML.load(text)
end

And(/^server fixture "([^"]+)"$/) do |number|
  @fixture_idx = number.to_i
  @fixture_cur = @fixture_hash[@fixture_idx]
  @type        = @fixture_cur['type']
  @template    = @fixture_cur['template']
  sf_content   = @fixture_cur['codestrapfile']
  sf_path      = File.join(@server_tmp, 'Codestrapfile')
  sf_file      = File.open(sf_path, 'w')
  sf_file.write(sf_content)
  sf_file.close
  ENV['CODESTRAPFILE']=sf_path
end

And(/^server capbility rest "(\/rest\/capability\.json)" is valid$/) do |url|
  $DEBUG=true
  get url
  $DEBUG=false
  expect(last_response.ok?).to be_truthy
  @capability = JSON.parse(last_response.body)
end

And(/^server object rest "(\/rest\/objects\.json)" is valid$/) do |url|
  get url
  expect(last_response.ok?).to be_truthy
  @codestrap_objects = JSON.parse(last_response.body)
end

And(/^server stub metadata rest "(\/rest\/stub\/metadata\.json)" is valid$/) do |url|
  get url
  expect(last_response.ok?).to be_truthy
  @codestrap_metadata = JSON.parse(last_response.body)
end

And(/^server strap metadata rest "(\/rest\/strap\/metadata\.json)" is valid$/) do |url|
  get url
  expect(last_response.ok?).to be_truthy
  @strap_metadata = JSON.parse(last_response.body)
end

And(/^server list contains the correct keys$/) do
  case @type
    when 'stub'
      expect(@codestrap_metadata).to have_key(@template)
    when 'strap'
      expect(@strap_metadata).to have_key(@template)
    else
      raise 'Error unknown type'
  end
end

Then(/^server file should contain the correct content$/) do
  if @type == 'stub'
    get @capability['urls']['stub']['file'] + '/' + @template

    potentials = Array(Codestrapfile.server.content).map { |dir| File.join(dir,@template + '.erb') }
    file = potentials.select { |f| File.exist? f }.first
    expect(file).to be_truthy

    file_sum = File.read(file)
    body_sum = last_response.body

    expect(body_sum).to eql(file_sum)
  end
  if @type == 'strap'
    # Fetch metadata
    get @capability['urls']['strap']['metadata']
    expect(last_response.ok?).to be_truthy
    metadata = JSON.parse(last_response.body)[@template]

    tmpdir = Dir.mktmpdir

    # Make directories
    metadata['files'].each do |file|
      next unless file['ftype'].eql?('directory')
      FileUtils.mkdir_p File.join(tmpdir, file['file'])
    end

    # Make files
    metadata['files'].each do |file|
      next unless file['ftype'] == 'file'
      get @capability['urls']['strap']['project'] + "/#{@template}/" + file['file']
      expect(last_response.ok?).to be_truthy
      File.open(File.join(tmpdir, file['file']), 'w') do |fh|
        fh.write last_response.body
      end
    end

    potentials = Array(Codestrapfile.server.content).map { |dir| File.join(dir,@template) }
    strap_dir = potentials.select { |f| File.directory? f }.first
    expect(diff_tree?(strap_dir, tmpdir)).to eq(0)
  end
end

And(/^server returns the right http code$/) do
  expect(last_response.ok?).to be_truthy
end
