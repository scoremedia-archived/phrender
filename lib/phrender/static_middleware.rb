class Phrender::StaticMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    path = File.join @app.site.asset_root, env['PATH_INFO']
    if File.exists?(path) && !File.directory?(path)
      [ 200, {}, [ File.read(path) ] ]
    else
      @app.call(env)
    end
  end
end

