require 'colorize'

class Phrender::Logger
  @print_color = !ENV.has_key?('DISABLE_COLOR')

  class << self
    MESSAGE_FORMAT = "%s: %s"

    def log_json(json)
      %w(console info error trace critical).each do |type|
        if json.has_key? type
          send type.to_sym, json[type]
        end
      end
    end

    def console(message)
      log MESSAGE_FORMAT % [ apply_color("CONSOLE", :magenta), message ]
    end

    def info(message)
      log MESSAGE_FORMAT % [ apply_color("INFO"), message ]
    end

    def error(message)
      log MESSAGE_FORMAT % [ apply_color("ERROR", :red), message ]
    end

    def trace(message)
      log MESSAGE_FORMAT % [ apply_color("TRACE", :cyan), message ]
    end

    def critical(message)
      log MESSAGE_FORMAT % [ apply_color("CRITICAL", :on_red), message ]
    end

    def log(msg, color = nil)
      message = "[%s] - %s" % [Time.now,  msg]
      $stdout.puts message
      $stdout.flush
    end

    protected

    def apply_color(message, color = nil)
      if !color.nil? && @print_color
        message.send(color.to_sym)
      else
        message
      end
    end

  end

end
