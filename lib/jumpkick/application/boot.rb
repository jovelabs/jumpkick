require "jumpkick/boot"
require "jumpkick/application"
require "mixlib/log"

class Jumpkick::Application::Boot < Jumpkick::Application

  NO_COMMAND_GIVEN = "You need to supply a sub-command (e.g. boot SUB-COMMAND)\n"

  banner "Usage: boot sub-command (options)"

  option :config_file,
    :short => "-c CONFIG",
    :long => "--config CONFIG",
    :description => "Specify the configuration file to use.",
    :proc => lambda { |path| File.expand_path(path, Dir.pwd) }

  verbosity_level = 0
  option :verbosity,
    :short => "-v",
    :long => "--verbose",
    :description => "Verbose output.  Use multiple times for more verbosity.",
    :proc => Proc.new { verbosity_level += 1 },
    :default => 0

  option :version,
    :short => "-V",
    :long => "--version",
    :description => "Display Jumpkick version.",
    :boolean => true,
    :proc => lambda { |v| puts "Jumpkick: #{::Jumpkick::VERSION}" },
    :exit => 0

  option :help,
    :short => "-h",
    :long => "--help",
    :description => "Display help.",
    :on => :tail,
    :boolean => true

  def run
    Mixlib::Log::Formatter.show_time = true
    validate_and_parse_options
    Jumpkick::Boot.run(ARGV, options)
    exit(0)
  end

  private

  def validate_and_parse_options
    if no_command_given?
      print_help_and_exit(1, NO_COMMAND_GIVEN)
    elsif no_subcommand_given?
      if (want_help? || want_version?)
        print_help_and_exit
      else
        print_help_and_exit(2, NO_COMMAND_GIVEN)
      end
    end
  end

  def no_subcommand_given?
    ARGV[0] =~ /^-/
  end

  def no_command_given?
    ARGV.empty?
  end

  def want_help?
    ARGV[0] =~ /^(--help|-h)$/
  end

  def want_version?
    ARGV[0] =~ /^(--version|-V)$/
  end

  def print_help_and_exit(exitcode=1, fatal_message=nil)
    Jumpkick::Log.error(fatal_message) if fatal_message

    begin
      self.parse_options
    rescue OptionParser::InvalidOption => e
      puts "#{e}\n"
    end
    puts self.opt_parser
    puts
    Jumpkick::Boot.list_commands
    exit exitcode
  end

end
