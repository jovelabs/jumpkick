require "jumpkick/logger"

class Jumpkick::Application

  def initialize
    super

    @logger = Jumpkick::Logger.new(STDOUT)
  end

  def run
    # REM
  end

end
