require 'phrender/phantom_js_engine'

require 'rack'

class Phrender::RackMiddleware
  def initialize(app, opts = {})
    @app = app
    @index_file = opts[:index_file]
    @javascript_paths = opts[:javascript_files]
    @raw_javascript = opts[:javascript].join(';')
    @phantom = Phrender::PhantomJSEngine.new(opts)
  end

  def call(env)
    status, headers, body = @app.call(env)
    if (status == 404 || headers['Content-Type'] == 'text/html')
      if (env['HTTP_USER_AGENT'].match(/PhantomJS/))
        [ 500, { 'Content-Type'  => 'text/html' }, [
        'Server Error: HTML file contains recursive lookup' ] ]
      else
        body = render(env['REQUEST_URI'])
        [ 200, { 'Content-Type'  => 'text/html' }, [ body ] ]
      end
    else
      [ status, headers, body ]
    end
  end

  protected

  def render(request_uri)
    program = load_js
    html = load_html
    @phantom.render(html, program, request_uri)
  end

  def load_html
    req = Rack::MockRequest.env_for('',
      'PATH_INFO' => @index_file,
      'REQUEST_METHOD' => 'GET'
    )
    status, headers, body = @app.call(req)
    parse_body body
  end

  def load_js
    js_from_files = @javascript_paths.map do |path|
      if path == :ember_driver
        Phrender::EMBER_DRIVER
      else
        req = Rack::MockRequest.env_for('',
          'PATH_INFO' => path,
          'REQUEST_METHOD' => 'GET'
        )
        status, headers, body = @app.call(req)
        parse_body body
      end
    end.join(';')
    program = js_from_files + @raw_javascript
    program.to_s
  end

  def parse_body(body)
    if body.respond_to? :each
      data = ''
      body.each{ |part| data << part }
      data
    else
      body.to_s
    end
  end

end
