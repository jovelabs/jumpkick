require "logger"

class Jumpkick::Logger < ::Logger

  SEVERITIES = Severity.constants.inject([]) {|arr,c| arr[Severity.const_get(c)] = c; arr}

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = Regexp.last_match[1]
      line = Regexp.last_match[2]
      method = Regexp.last_match[3]
      "#{File.basename(file)}:#{line}:#{method} | "
    else
      "UNKNOWN_CALLER | "
    end
  end

  def add(severity, message = nil, progname = nil, &block)
    if @logdev.nil? || (@level > severity)
      return true
    end

    who_called = parse_caller(caller[1])

    message = [message, progname, (block && block.call)].delete_if{|i| i == nil}.join(': ')

    message = "%19s.%-6d | %5s | %5s | %s%s\n" % [Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"), Time.now.usec, Process.pid.to_s, SEVERITIES[severity], who_called, message]

    @logdev.write(message)

    true
  end

end
