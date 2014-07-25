require 'spec_helper'
require 'phrender/phantom_js_engine'

describe 'Phrender::PhantomJSEngine' do
  let(:phantom) {
    Phrender::PhantomJSEngine.new(:timeout => 10000, :ssl => false)
  }

  let(:index) {
    File.read(File.expand_path('../phantom_js_engine/index.html', __FILE__))
  }

  let(:app) {
    File.read(File.expand_path('../phantom_js_engine/app.js', __FILE__))
  }

  it 'renders a simple page' do
    whitespace_regex = /(\n|^ +)/
    html = <<-HTML.strip_heredoc.gsub(whitespace_regex, '')
      <html>
        <head>
          <title>Phrender The Prerenderer</title>
        </head>
        <body>
          <p>Hello!</p>
        </body>
      </html>
    HTML
    expect(phantom.render(index, app).gsub(whitespace_regex, '')).to eq(html)
  end
end
