require "phrender/version"
require "phrender/drivers"
require "phrender/engine"
require "phrender/site"
require "phrender/static_middleware"

require "rack"

class Phrender
  attr_reader :site
  attr_reader :engine

  def initialize(site, opts = {})
    timeout = opts[:timeout] || 10000
    @site = site
    site.save_source
    engine_opts = {
      timeout: timeout,
      index_file: @site.index_file,
      script: @site.source_file_path
    }
    @engine = Phrender::Engine.new engine_opts
    at_exit do
      cleanup
    end
  end

  def app
    app = self
    Rack::Builder.new do
      use Rack::CommonLogger
      use Phrender::StaticMiddleware
      run app
    end
  end

  def cleanup
    puts "Cleaning up..."
    @site.dispose
  end

  def call(env)
    request = Rack::Request.new env
    path = request.path_info
    host = request.host

    url = "http://#{host}#{path}"
    html = @engine.render url

    response = Rack::Response.new
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.write html
    response.finish
  end

end

