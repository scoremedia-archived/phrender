require 'spec_helper'
require 'phrender/rack_static'

describe 'Phrender::RackStatic' do
  let(:root) { File.expand_path '../rack_static', __FILE__ }
  let(:app) {
    Phrender::RackStatic.new({
      :asset_root => root,
      :index_file => 'phrender.html',
      :javascript_files => [
        'app.js'
      ],
      :javascript => [
        "App.run()"
      ]
    })
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
