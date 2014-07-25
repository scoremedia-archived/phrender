require 'phrender/phantom_js_engine'
require 'phrender/rack_middleware'

require 'rack'

class Phrender::RackStatic < Phrender::RackMiddleware
  def initialize(opts = {})
    asset_root = opts.delete :asset_root
    app = Rack::File.new(asset_root)
    super(app, opts)
  end
end
