require 'colorize'

class Phrender::Engine::PhantomLogger
  MESSAGE_FORMAT = "%s: %s"

  def log_json(json)
    %w(console info error trace critical).each do |type|
      if json.has_key? type
        send type.to_sym, json[type]
      end
    end
  end

  def console(message)
    log MESSAGE_FORMAT % [ "CONSOLE".magenta, message ]
  end

  def info(message)
    log MESSAGE_FORMAT % [ "INFO", message ]
  end

  def error(message)
    log MESSAGE_FORMAT % [ "ERROR".red, message ]
  end

  def trace(message)
    log MESSAGE_FORMAT % [ "TRACE".cyan, message ]
  end

  def critical(message)
    log MESSAGE_FORMAT % [ "CRITICAL".black.on_red, message ]
  end

  def log(msg)
    message = "[%s] - %s" % [Time.now,  msg]
    $stdout.puts message
    $stdout.flush
  end

end
