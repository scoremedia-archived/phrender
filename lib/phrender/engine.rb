class Phrender::Engine
  require 'phrender/engine/phantom_js'

  def initialize(opts = {})
    browser_class = opts.delete(:browser_class) || Phrender::Engine::PhantomJs
    @browser = browser_class.new(opts)
  end

  def render(url)
    @browser.run url: url
  end

end
