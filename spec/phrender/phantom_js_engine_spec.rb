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

  it 'generates a startup command with escaped json' do
    command = phantom.app_cmd(index, app, 'http://localhost')
    expect(command).to match(
      /phantomjs (.+?)phrender\/lib\/phrender\/support\/phantom_bridge.js/
    )
    expect(command).to include("--ignore-ssl-errors=true")
    expect(command).to include("<html>")
    expect(command).to include("use strict")
  end

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
