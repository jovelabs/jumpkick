require "jumpkick/application"

class Jumpkick::Application::Boot < Jumpkick::Application

  def initialize
    super
  end

  def run
    super

    @logger.info("Hello World!")
  end

end
