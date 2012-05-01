require "mixlib/cli"

class Jumpkick::Application
  include Mixlib::CLI

  def initalize
    super

    trap("TERM") do
      Jumpkick::Application.fatal!("SIGTERM received, stopping", 1)
    end

    trap("INT") do
      Jumpkick::Application.fatal!("SIGINT received, stopping", 2)
    end

    trap("QUIT") do
      Jumpkick::Log.info("SIGQUIT received, call stack:\n  #{caller.join("\n  ")}")
    end

    trap("HUP") do
      Jumpkick::Log.info("SIGHUP received, reconfiguring")
      reconfigure
    end
  end

  def reconfigure
    # configure_jumpkick
    # configure_logging
  end

  def run
    # reconfigure
    # setup_application
    # run_application
  end

  def configure_logging
    Jumpkick::Log.init(Jumpkick::Config[:log_location])
    if (Jumpkick::Config[:log_location] != "STDOUT") && STDOUT.tty? && (!Jumpkick::Config[:daemonize])
      stdout_logger = Logger.new(STDOUT)
      STDOUT.sync = true
      stdout_logger.formatter = Jumpkick::Log.logger.formatter
      Jumpkick::Log.loggers << stdout_logger
    end
    Jumpkick::Log.level = Jumpkick::Config[:log_level]
  end

  class << self

    def fatal!(message, exit_code=-1)
      Jumpkick::Log.fatal(message)
      Process.exit(exit_code)
    end

    def exit!(message, exit_code=-1)
      Jumpkick::Log.debug(message)
      Process.exit(exit_code)
    end

  end

end
