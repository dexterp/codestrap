require 'json'
require 'sinatra/base'
require 'codestrap'
require 'codestrap/server/version'
require 'uri'
require 'codestrap/config'

module Codestrap
  module Server
    class Rest < Sinatra::Base

      # Settings
      #set :environment, :production

      # Sessions
      #set :sessions, true

      # Logging to STDERR
      set :logging, false

      # Applications root directory
      #set :root, 'path/to/root'

      # Serve files from public directory
      set :static, false

      # Public folder
      #set :public_folder, 'path/to/static/files'

      # Views folder defaults to static_dir/views
      #set :views, Proc.new { File.join(dir, 'templates')}

      # Enable/disable built in web server
      #set :run, false

      # Built in web servers. Following is default
      #set :server, %w[thin mongrel webrick]

      # Binding
      #set :bind, '0.0.0.0'

      # Set port
      #set :port, 9494

      # Set app file. Calculates :root, :public_folder, :views
      #set :app_file, __FILE__

      # Propagate errors to server or rack
      #set :raise_errors

      # Show error pages
      #set :show_exceptions, true

      version    = Codestrap::Server::VERSION


      # TODO - hardcode2config Host to advertise
      host       = 'codestrap.test.domain'

      # TODO - hardcode2config port to advertise
      port       ||= settings.port

      # TODO - hardcode2config Schema to advertise. http or https
      scheme     = 'http'

      # Objects
      urlobjects = '/rest/objects.json'
      get urlobjects do
        codestrap = Codestrap::Core.new()
        obj       = Codestrap::Object::Factory.new
        obj.dirs  = codestrap.config.server.objects
        content_type :json
        case params[:prettyprint]
          when 'true'
            JSON.pretty_generate(obj.to_hash)
          else
            obj.to_hash.to_json
        end
      end

      # BP metadata
      urlstrapmetadata = '/rest/strap/metadata.json'
      get urlstrapmetadata do
        name      = params[:name]
        codestrap = Codestrap::Core.new()
        paths     = codestrap.config.server.content
        output    = codestrap.strap_metadata(name, nil, paths)
        content_type :json
        case params[:prettyprint]
          when 'true'
            JSON.pretty_generate(output)
          else
            output.to_json
        end
      end

      # Codestrap metadata
      urlcodestrapmetadata = '/rest/stub/metadata.json'
      get urlcodestrapmetadata do
        name      = params[:name]
        codestrap = Codestrap::Core.new()
        paths     = codestrap.config.server.content
        output    = codestrap.stub_metadata(name, nil, paths)
        content_type :json
        case params[:prettyprint]
          when 'true'
            JSON.pretty_generate(output)
          else
            output.to_json
        end
      end

      # Boilerplate content
      urlstrapproject = '/rest/strap/project'
      get "#{urlstrapproject}/:name/*" do
        # TODO - Rest error message
        # TODO - Logging
        # TODO - Handle all files
        name      = params[:name]
        data_file = params[:splat].first
        file_path = nil
        codestrap = Codestrap::Core.new()
        paths     = codestrap.config.server.content
        codestrap.strap_metadata(name, {src: true, ftype: true, mode: true}, paths).values.each do |data|
          data[:files].each do |file|
            next unless File.expand_path(file[:file]).eql?(File.expand_path(data_file))
            file_path = file[:src]
            break
          end
          break
        end
        send_file file_path
      end

      # File content
      urlcodestrapfile = '/rest/stub/file'
      get "#{urlcodestrapfile}/:name" do
        # TODO - Rest error message
        # TODO - Logging
        # TODO - Handle all files
        name      = params[:name]
        codestrap = Codestrap::Core.new()
        paths     = codestrap.config.server.content
        file_path = codestrap.stub_metadata(name, {src: true, ftype: true, mode: true}, paths)[name][:src]
        send_file file_path
      end

      cap = {
          version: version,
          urls:    {
              objects:   urlobjects,
              stub: {
                  metadata: urlcodestrapmetadata,
                  file:     urlcodestrapfile,
              },
              strap:     {
                  metadata: urlstrapmetadata,
                  project:  urlstrapproject
              }
              # TODO - Packages
          }
      }

      # Capabilities
      get '/rest/capability.json' do
        content_type :json
        case params[:prettyprint]
          when 'true'
            JSON.pretty_generate(cap)
          else
            cap.to_json
        end
      end
    end
  end
end

