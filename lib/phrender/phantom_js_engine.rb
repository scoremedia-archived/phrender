require 'phrender/logger'
require 'phrender/phantom_js_session'

require 'open3'
require 'multi_json'

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
      "--ignore-ssl-errors=true"
    ]
    @boot_cmd.push "--ssl-protocol=%s" % [ @ssl_protocol ] if @ssl_protocol
  end

  def render(html, javascript, url = nil)
    command = app_cmd(html, javascript, url)
    session = Phrender::PhantomJSSession.new command, @timeout

    begin
      sleep @poll_interval
      parse_output(session)
    end while !session.expired? && !session.rendered

    # Clean up phantom
    session.shutdown

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

  def app_cmd(html, javascript, url)
    program_options = { :html => html,
                        :javascript => javascript,
                        :url => url,
                        :timeout => @timeout }
    encoded_options = MultiJson.dump(MultiJson.dump(program_options))
    "%s %s" % [ @boot_cmd.join(' '), encoded_options ]
  end

  protected

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

