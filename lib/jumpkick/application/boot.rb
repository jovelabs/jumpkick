require "jumpkick/application"

class Jumpkick::Application::Boot < Jumpkick::Application

  def run
    super
    @logger = Jumpkick::Logger.new(STDOUT)

    @logger.info("Hello World!")
  end

end
