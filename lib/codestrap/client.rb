require 'digest'
require 'etc'
require 'net/http'
require 'json'
require 'tmpdir'
require 'tempfile'
require 'fileutils'

module Codestrap
  class Client
    def initialize(url)
      uri     = URI url
      @url    = url
      @scheme = uri.scheme
      @host   = uri.host
      @port   = uri.port
      self.capability uri
    end

    # Cache directory path. Will be created if directory doesn't exist
    #
    # @return [String]
    def cache
      @cache ||= begin
        cache = File.join(Dir.tmpdir, Etc.getlogin, digest, 'codestrap')
        FileUtils.mkpath cache unless File.exist? cache
        @cache = cache
      end
    end

    # Content cache directory path. Will be created if directory doesn't exists
    #
    # @return [String]
    def cache_content
      @cache_content ||= begin
        cache_content = File.join(cache, 'content')
        FileUtils.mkpath cache_content unless File.exist? cache_content
        @cache_content = cache_content
      end
    end

    # Object cache directory path. Will be created if directory doesn't exists
    #
    # @return [String]
    def cache_object
      @cache_object ||= begin
        cache_object = File.join(cache, 'objects')
        FileUtils.mkpath cache_object unless File.exist? cache_object
        @cache_object = cache_object
      end
    end

    # Return MD5 hexdigest digest of the capability URL
    #
    # @return [String]
    def digest
      @digest ||= (Digest::MD5.hexdigest @url)
    end

    # Sets capability URL. Returns JSON capability document as hash.
    #
    # @param [URI] uri
    #   Capability URI
    # @return [Hash|nil]
    #   JSON document as a Hash
    def capability(uri=nil)
      return @capability unless uri
      begin
        response    = Net::HTTP.get_response URI uri
        @capability = JSON.parse(response.body)
        return @capability
      rescue Errno::ECONNREFUSED
        nil
      end
    end

    def stubmetadata(file)
      return nil unless @capability
      response = Net::HTTP.get_response URI stubmetadataurl + '?name=' + file
      JSON.parse(response.body)
    end

    def stubmetadataurl
      return nil unless @capability
      "#{@scheme}://#{@host}:#{@port}#{@capability['urls']['stub']['metadata']}"
    end

    def stublist
      return nil unless @capability
      response = Net::HTTP.get_response URI stubmetadataurl
      JSON.parse(response.body).keys
    end

    def stubfileurl
      return nil unless @capability
      "#{@scheme}://#{@host}:#{@port}#{@capability['urls']['stub']['file']}"
    end

    def strapmetadata(project)
      return nil unless @capability
      response = Net::HTTP.get_response URI strapmetadataurl + '?name=' + project
      JSON.parse(response.body)[project]
    end

    def straplist
      return nil unless @capability
      response = Net::HTTP.get_response URI strapmetadataurl
      JSON.parse(response.body).keys
    end

    def strapmetadataurl
      return nil unless @capability
      "#{@scheme}://#{@host}:#{@port}#{@capability['urls']['strap']['metadata']}"
    end

    def strapprojecturl
      return nil unless @capability
      "#{@scheme}://#{@host}:#{@port}#{@capability['urls']['strap']['project']}"
    end

    def objecturl
      return nil unless @capability
      "#{@scheme}://#{@host}:#{@port}#{@capability['urls']['objects']}"
    end

    def getobjects(objects=nil)
      return {} unless @capability
      response = Net::HTTP.get_response URI objecturl
      JSON.parse(response.body)
    end

    def getstub(codestrap)
      return nil unless @capability
      path     = File.join(cache_content, codestrap + '.erb')

      # Get metadata
      metadata = stubmetadata codestrap
      if not metadata or metadata.empty?
        return nil
      end

      # create file
      response = Net::HTTP.get_response URI stubfileurl + "/#{codestrap}"
      File.open(path, 'w') do |file|
        file.write response.body
      end

      path
    end

    def getstrap(project)
      return nil unless @capability
      path     = File.join(cache_content, project)

      # Get metadata
      metadata = strapmetadata project
      if not metadata or metadata.empty?
        return nil
      end

      # Make directories
      metadata['files'].each do |file|
        next unless file['ftype'].eql?('directory')
        FileUtils.mkdir_p File.join(path, file['file'])
      end

      # Make files
      metadata['files'].each do |file|
        next unless file['ftype'].eql?('file')
        response = Net::HTTP.get_response URI strapprojecturl + "/#{project}/" + file['file']
        File.open(File.join(path, file['file']), 'w') do |fh|
          fh.write response.body
        end
      end

      path
    end
  end
end
