class Phrender::PhantomJSSession
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
