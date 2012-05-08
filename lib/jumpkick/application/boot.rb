
require "jumpkick/application"
require "jumpkick/application/boot/options"

class Jumpkick::Application::Boot < Jumpkick::Application

  VERSION = "0.0.1"

  def initialize
    @options = Options.parse(ARGV)

    super
  end

  def configure
    super

    @logger.info("Configuring...")
  end

  def run
    super

    @logger.info("Hello World!")

    puts @options
  end

end
