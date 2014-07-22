require 'spec_helper'
require 'phrender/rack_static'

describe 'Phrender::RackStatic' do
  let(:root) { File.expand_path '../rack_static', __FILE__ }
  let(:app) {
    p = Phrender::RackStatic.new(root)
    p.index_file = 'phrender.html'
    p.add_javascript_file 'app.js'
    p.add_javascript 'App.run'
    p.rack_app
  }

  it 'runs the app contained in the referenced assets' do
    get('/')
    expect(last_response.body).to eq('<html><head><title>Phrender The Prerenderer</title></head><body><p>Hello!</p></body></html>')
  end

  it 'resolves static assets' do
    get('/files/static.txt')
    expect(last_response.body.strip).to eq('The body of a static file.')
  end

end
