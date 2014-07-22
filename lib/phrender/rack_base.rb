class Phrender::RackBase
  class Proxy
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

  def initialize(*args)
    @javascript_paths = []
    @raw_javascript = ''
    Proxy.host = self
  end

  def rack_app
    raise NotImplementedError
  end

  def render(path, app)
    raise NotImplementedError
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

end
