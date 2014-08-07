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
    @req = Rack::Request.new(env)

    @req.update_param :phrender_request, 'true'

    # Check if the next middleware can handle the request
    status, headers, body = @app.call(@req.env)

    # If it can't, or if it's just the index file delivered via aliasing for
    # pushstate, do phrender stuff.
    if status == 404 || headers['Push-State-Redirect']
      # If it's phantom making the request, then the phrender index file has
      # a request that the upstream server can't resolve, so catch it, instead
      # of recursively invoking the index
      if @req.user_agent && @req.user_agent.match(/PhantomJS/)
        [ 500, { 'Content-Type'  => 'text/html' }, [
        'Server Error: HTML file contains recursive lookup' ] ]
      else
        # Render the page
        body = render(@req.url)
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
    req = @req.dup
    req.path_info = @index_file

    # Attach a param to indicate that it's phrender requesting the page. This is
    # only useful if the index file is delivered via a dynamic backend. Ignored
    # otherwise.
    req.update_param('phrender', true)
    req.env['REQUEST_METHOD'] = 'GET'

    status, headers, body = @app.call(req.env)
    parse_body body
  end

  def load_js
    js_from_files = @javascript_paths.map do |path|
      if path == :ember_driver
        Phrender::EMBER_DRIVER
      else
        req = @req.dup
        req.path_info = path
        req.env['REQUEST_METHOD'] = 'GET'

        status, headers, body = @app.call(req.env)
        parse_body body
      end
    end.join(';')
    program = js_from_files + @raw_javascript
    program.to_s
  end

  def parse_body(body)
    # Rack responses must respond to each, which is generally a polyfil that
    # yields the response, so reassemble it here, or just treat it like a
    # string.
    if body.respond_to? :each
      data = ''
      body.each{ |part| data << part }
      data
    else
      body.to_s
    end
  end

end
