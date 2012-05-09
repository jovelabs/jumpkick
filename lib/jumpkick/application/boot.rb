require "jumpkick/application"
require "jumpkick/application/boot/options"

require "chef"
require "chef/knife"
require "chef/knife/bootstrap"
require "chef/knife/core/bootstrap_context"
require "chef/knife/ssh"
require "net/ssh/multi"

class Jumpkick::Application::Boot < Jumpkick::Application

  def initialize
    @options = Options.parse(ARGV)

    super
  end

  def run
    super
    @logger.debug(@options)
    @logger.info("Preparing bootstrap for '#{@options.address}'.")


    bootstrap = ::Chef::Knife::Bootstrap.new
    ui = ::Chef::Knife::UI.new(STDOUT, STDERR, STDIN, bootstrap.config)
    bootstrap.ui = ui
    bootstrap.name_args = [@options.address]
    bootstrap.config[:use_sudo] = true
    bootstrap.config[:template_file] = @options.template

    @logger.info("Running bootstrap for '#{@options.address}'.")
    bootstrap.run
  end

end
