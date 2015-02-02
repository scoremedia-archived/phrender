require 'phrender/logger'
require 'phrender/phantom_js_session'

require 'open3'
require 'multi_json'
require 'tempfile'

class Phrender::PhantomJSEngine

  def initialize(opts = {})
    # Apply defaults
    opts = { :timeout => 10000, :ssl => false }.merge opts

    @poll_interval = 0.1
    @timeout = opts[:timeout] / 1000.0
    @ssl_protocol = opts.delete :ssl
    @logger = Phrender::Logger

    phantom_program = File.expand_path '../support/phantom_bridge.js', __FILE__

    MultiJson.use :json_gem

    @boot_cmd = [
      'phantomjs',
      phantom_program,
      "--ignore-ssl-errors=true",
      "--load-images=false"
    ]
    @boot_cmd.push "--ssl-protocol=%s" % [ @ssl_protocol ] if @ssl_protocol
  end

  def render(html, javascript, url = nil)
    javascript_file = make_temp_file(javascript, 'file.js')
    html_file = make_temp_file(html, 'file.html')
    program_options = { :html => html_file.path,
                        :javascript => javascript_file.path,
                        :url => url,
                        :timeout => @timeout * 1000.0 }

    session = Phrender::PhantomJSSession.new @boot_cmd.join(' '), @timeout

    session.stdin.puts MultiJson.dump(program_options)
    session.stdin.close

    begin
      sleep @poll_interval
      parse_output(session)
    end while !session.expired? && !session.rendered

    # Clean up phantom
    session.shutdown

    # Clean up temp files
    javascript_file.unlink
    html_file.unlink

    # Feed something out the chain
    if session.rendered
      session.page
    elsif session.expired?
      @logger.critical "PhantomJS timed out. Likely a javascript execution error."
      ''
    else
      @logger.critical "Phantom terminated without expiring or returning anything. This is bad."
      ''
    end
  end

  protected

  def make_temp_file(data, name)
    file = Tempfile.new(name)
    file.write(data)
    file.close
    file
  end

  def parse_output(session)
    output = session.stdout.gets
    begin
      data = JSON.parse output
      if [ 'error', 'trace', 'console' ].any? { |key| data.has_key? key }
        @logger.log_json data
      elsif data.has_key? 'page'
        session.rendered = true
        session.page = data['page']
      end
      session.rendered
    rescue
      false
    end
  end

end

