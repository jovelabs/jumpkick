require "jumpkick/logger"

class Jumpkick::Application

  def initalize
    @logger = Jumpkick::Logger.new(STDOUT)
  end

  def run
    # REM
  end

end
