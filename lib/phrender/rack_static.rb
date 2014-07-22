require 'phrender/phantom_js_engine'

require 'rack'

class Phrender::RackStatic
  class App
    class << self
      attr_accessor :host
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      self.class.host.call(env, @app)
    end
  end

  attr_accessor :index_file

  def initialize(root_directory, opts = {})
    @phantom = Phrender::PhantomJSEngine.new(opts)
    @root_directory = root_directory
    @javascript_paths = []
    @raw_javascript = ''
    App.host = self
  end

  def rack_app
    static_directory = @root_directory
    @app ||= Rack::Builder.new do
      use App
      run Rack::File.new(static_directory)
    end
  end

  def call(env, app)
    status, headers, body = app.call(env)
    if status == 404
      body = render(env['PATH_INFO'], app)
      [ 200, { 'Content-Type'  => 'text/html' }, body ]
    else
      [ status, headers, body ]
    end
  end

  def add_javascript_file(path)
    @javascript_paths.push path
  end

  def add_javascript(code)
    @raw_javascript << ';' + code
  end

  protected

  def render(path, app)
    program = load_js(app)
    html = load_html(app)
    @phantom.render(html, program)
  end

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
