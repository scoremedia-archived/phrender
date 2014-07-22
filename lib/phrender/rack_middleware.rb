require 'phrender/phantom_js_engine'
require 'phrender/rack_base'

require 'rack'

class Phrender::RackMiddleware < Phrender::RackBase
  def initialize(backend, opts = {})
    @phantom = Phrender::PhantomJSEngine.new(opts)
    @backend = backend
    super
  end

  def rack_app
    backend = @backend
    @app ||= Rack::Builder.new do
      use Proxy
      run backend
    end
  end

  def render(path, app)
    program = load_js(app)
    html = load_html(app)
    @phantom.render(html, program)
  end

  protected

  def load_html(app)
    req = Rack::MockRequest.env_for('',
      'PATH_INFO' => @index_file,
      'REQUEST_METHOD' => 'GET'
    )
    status, headers, body = app.call(req)
    body
  end

  def load_js(app)
    js_from_files = @javascript_paths.map do |path|
      if path == :ember_driver
        Phrender::EMBER_DRIVER
      else
        req = Rack::MockRequest.env_for('',
          'PATH_INFO' => path,
          'REQUEST_METHOD' => 'GET'
        )
        status, headers, body = app.call(req)
        body
      end
    end.join(';')
    program = js_from_files + @raw_javascript
    program
  end

end
