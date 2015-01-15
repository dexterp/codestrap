require 'erb'
require 'find'
require 'fileutils'
require 'ostruct'
require 'codestrap/boilerplate/abstract'
require 'codestrap/namespace'
require 'codestrap/patch'
require 'tmpdir'

module Codestrap
  module Boilerplate
    # Standard project renderer
    #
    class Standard < Abstract

      def initialize(*args)
        self.working_dir
      end

      def pre
        @compiled ||= []

        # Take ignored array from Codestrap.config
        ignore_hash = {}
        Array(self.ignore).each do |ignore|
          ignore_hash[ignore] = true
        end
        Find.find(self.src) do |src|
          # Ignore files
          if ignore_hash.has_key? File.basename(src)
            Find.prune
          end

          proj_path = String(src.gsub(/^#{Regexp.escape(self.src)}/, ''))

          # Destination path substitutions
          proj_path =~ /:(?:stub|strap):(.+?):/
          object      = $1
          replacement = proj_path.gsub(/:(?:stub|strap):.+?:/, "<%= #{object} %>")
          if proj_path != replacement
            # Regex replacement
            ns        = Codestrap::Namespace.new(self.objects.objects)
            erb       = ERB.new(replacement)
            proj_path = erb.result(ns.get_binding)
          end

          dst = File.join(self.working_dir, proj_path)

          # Directories
          if File.directory? src
            @compiled.push({file: proj_path, src: src, dst: dst, type: :dir})
            next
          end

          # Files
          file = Codestrap::Patch::File.new src
          if file.stat.file?
            # Read modeline
            if file.has_mode_line?
              # Templates
              @compiled.push({file: proj_path, src: src, dst: dst, type: file.template})
            else
              # Files
              @compiled.push({file: proj_path, src: src, dst: dst, type: :regular})
            end
            next
          end
        end
      end

      def execute
        @compiled.each do |obj|
          case obj[:type]
            when :dir
              FileUtils.mkpath obj[:dst]
            when :regular
              FileUtils.install obj[:src], obj[:dst]
            when :erb
              renderer         = Codestrap::Template::Factory.new('Standard').construct
              renderer.objects = self.objects
              renderer.src     = obj[:src]
              renderer.dst     = obj[:dst]
              renderer.pre
              renderer.execute
              renderer.post
              renderer.to_disk
            else
              raise Exception, "Unknown type: #{obj[:type].to_s}"
          end
        end
      end
    end
  end
end