require 'tempfile'

class Phrender::Site
  attr_accessor :index_file
  attr_accessor :asset_root

  def initialize
    @source = ''
    @file = nil
  end

  def add_source(source)
    @source << ';'
    @source << source
  end

  def add_source_file(path)
    @source << ';'
    @source << File.read(path)
  end

  def save_source
    dispose if @file
    @file = Tempfile.new('phrender.js')
    @file.write @source
    # This flushes the Tempfile's IO buffer. Otherwise there may be content
    # left to write. It's weird.
    @file.size
  end

  def source_file_path
    @file ? @file.path : nil
  end

  def dispose
    @file.close
    @file.unlink
  end
end

