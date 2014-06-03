require 'multi_json'
require 'open3'

require 'phrender/engine/phantom_logger'

class Phrender::Engine::PhantomJs

  class Session
    attr_accessor :stdin
    attr_accessor :stdout
    attr_accessor :stderr
    attr_accessor :wait_thr
    attr_accessor :rendered
    attr_accessor :page

    def initialize(cmd, timeout)
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(cmd)
      @start_time = Time.now
      @rendered = false
      @timeout = timeout
    end

    def expired?
      (Time.now - @start_time) >= @timeout
    end

    def shutdown
      @stdin.close
      @stdout.close
      @stderr.close
      begin
        Process.kill("TERM", @wait_thr.pid)
      rescue Errno::ESRCH
      end
    end
  end

  def initialize(opts = {})
    setup_multi_json

    @poll_interval = 0.1
    @timeout = opts[:timeout] / 1000.0
    @logger = Phrender::Engine::PhantomLogger.new

    phantom_program = File.expand_path '../phantom_bridge.js', __FILE__
    @boot_cmd = [
      'phantomjs',
      phantom_program,
      shell_json(opts),
    ].join(' ')
  end

  def setup_multi_json
    MultiJson.use :json_gem
  end

  def shell_json(hash)
    string = MultiJson.dump(MultiJson.dump(hash))
    string
  end

  def read_page(session)
    output = session.stdout.gets
    begin
      data = MultiJson.load output
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

  def run(opts = {})
    session = Session.new "#{@boot_cmd} #{shell_json opts}", @timeout
    begin
      sleep @poll_interval
      read_page(session)
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
end

