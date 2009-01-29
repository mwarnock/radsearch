require 'fileutils'

module PluginUtils

  class ResourceInstallation
    attr_reader :source  

    def initialize(src, dest, opts = {})
      @source = src
      @destination = dest
      @options = opts
    end

    def overwrites?
      @options[:overwrite]
    end

    def message
      @options[:message]
    end

    protected 
    def install_by_method(src_root, dest_root, meth)
      file_src = File.join(src_root, @source)
      file_dest = File.join(dest_root, @destination)
      file_chk = File.join(file_dest, File.basename(file_src))
      if !overwrites?
        return(nil) if File.exist?(file_chk)
      end
      puts(message) if !message.nil?
      FileUtils.send(meth.to_sym, file_src, file_dest, {:verbose => true})
    end
  end

  class FileInstallation < ResourceInstallation

    def install!(src_root, dest_root)
      install_by_method(src_root, dest_root, :cp)
    end

  end

  class DirectoryInstallation < ResourceInstallation
    def install!(src_root, dest_root)
      install_by_method(src_root, dest_root, :cp_r)
    end
  end

  class Installer
    attr_reader :source_root, :destination_root

    def initialize(plugin_name)
      @source_root = File.expand_path(File.join(RAILS_ROOT, "vendor/plugins/#{plugin_name}"))
      @destination_root = File.expand_path(RAILS_ROOT)
      @files_to_copy = []
      @directories_to_copy = []
      yield self if block_given?
    end

    def install_file(src, dest, opts={})
      @files_to_copy.push(FileInstallation.new(src, dest, opts))
    end
  
    def install_directory(src, dest, opts={})
      @directories_to_copy.push(DirectoryInstallation.new(src, dest, opts))
    end

    def directories_to_install
      @directories_to_copy.map(&:source)
    end

    def files_to_install
      @files_to_copy.map(&:source)
    end

    def installation_of(src)
      @files_to_copy.detect { |fi| fi.source == src }
    end

    def installation_of_directory(src)
      @directories_to_copy.detect { |di| di.source == src }
    end

    def install!
      @files_to_copy.each { |fi| fi.install!(@source_root, @destination_root) }
      @directories_to_copy.each { |di| di.install!(@source_root, @destination_root) }
    end
  end

end
