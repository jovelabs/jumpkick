require "optparse"
require "ostruct"

class Options

  def self.parse(args)

    options = OpenStruct.new
    options.verbose = false
    options.logger = STDOUT

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: boot [options]"
      opts.separator("Version: #{Jumpkick::Application::Boot::VERSION}")

      opts.separator("")
      opts.separator("Output Options:")

      opts.on("-v", "--[no-]verbose", "Verbose output") do |v|
        options.verbose = v
      end

      opts.on("-l", "--logger=OUTPUT", "Specify logging output") do |l|
        options.logger = case l.upcase.strip
        when "STDOUT"
          STDOUT
        when "STDERR"
          STRERR
        else
          l
        end
      end

      opts.separator("")
      opts.separator("General Options:")

      opts.on_tail("-V", "--version", "Show version") do
        puts "boot v#{Jumpkick::Application::Boot::VERSION}"
        ::Kernel.exit
      end

      opts.on_tail("-h", "--help", "Show help") do
        puts opts
        ::Kernel.exit
      end
    end

    opts.parse!(args)
    options
  end

end
