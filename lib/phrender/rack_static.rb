require 'phrender/phantom_js_engine'
require 'phrender/rack_base'

require 'rack'

class Phrender::RackStatic < Phrender::RackBase
  def initialize(root_directory, opts = {})
    @phantom = Phrender::PhantomJSEngine.new(opts)
    @root_directory = root_directory
    super
  end

  def rack_app
    static_directory = @root_directory
    @app ||= Rack::Builder.new do
      use Proxy
      run Rack::File.new(static_directory)
    end
  end

  def render(path, app)
    program = load_js(app)
    html = load_html(app)
    @phantom.render(html, program)
  end

  protected

  def load_html(app)
    File.read File.join(@root_directory, @index_file)
  end

  def load_js(app)
    js_from_files = @javascript_paths.map do |path|
      if path == :ember_driver
        Phrender::EMBER_DRIVER
      else
        File.read File.join(@root_directory, path)
      end
    end.join(';')
    program = js_from_files + @raw_javascript
    program
  end

end