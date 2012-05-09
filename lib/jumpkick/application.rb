require "jumpkick/logger"

class Jumpkick::Application

  def initialize
    @logger = Jumpkick::Logger.new(@options.log)
    @logger.level = Jumpkick::Logger.const_get(@options.log_level.to_s.upcase)

    trap("TERM") do
      @logger.fatal("SIGTERM received; exiting!")
      Kernel.exit(1)
    end

    trap("INT") do
      @logger.fatal("SIGINT received; exiting!")
      Kernel.exit(2)
    end

    trap("QUIT") do
      @logger.fatal("SIGQUIT received; exiting!")
    end

    trap("HUP") do
      @logger.info("SIGHUP received; reloading...")
      configure
    end
  end

  def run
  end

end
