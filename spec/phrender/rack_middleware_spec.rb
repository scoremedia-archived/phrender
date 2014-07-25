require 'spec_helper'
require 'phrender/rack_middleware'
require 'sprockets'

describe 'Phrender::RackMiddleware' do
  let(:root) { File.expand_path '../rack_middleware', __FILE__ }
  let(:backend) {
    b = Sprockets::Environment.new(root)
    b.append_path 'assets'
    b
  }
  let(:app) {
    _backend = backend # Needed because builder changes the block's context
    Rack::Builder.new do
      use Phrender::RackMiddleware, {
        :index_file => 'phrender.html',
        :javascript_files => [
          'app.js'
        ],
        :javascript => [
          "App.run()"
        ]
      }
      run _backend
    end
  }

  it 'runs the app contained in the referenced assets' do
    get('/')
    whitespace_regex = /(\n|^ +)/
    html = '<html><head><title>Phrender The Prerenderer</title></head><body><h1>What a page!</h1><p>Hello!</p></body></html>'
    expect(last_response.body.gsub(whitespace_regex, '')).to eq(html)
  end
end
