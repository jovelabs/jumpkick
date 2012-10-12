require "optparse"
require "ostruct"

class Options

  def self.parse(args)

    options = OpenStruct.new
    options.log = STDOUT
    options.log_level = :info
    options.address = nil
    options.template = File.join(File.dirname(__FILE__), "templates", "ubuntu.erb")
    options.user = "ubuntu"
    options.identity = nil
    options.amqp_password = nil
    options.admin_password = nil
    options.hostname = nil

    mandatory = [:address, :hostname, :amqp_password, :admin_password]

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: boot [options]"

      opts.separator("")
      opts.separator("Bootstrap Options:")

      opts.on("--address=ADDRESS", "Bootstrap and build a new chef server") do |address|
        options.address = address
      end

      opts.on("--template=TEMPLATE", "Bootstrap template") do |template|
        options.template = template
      end

      opts.on("--user=USER", "Bootstrap user") do |user|
        options.user = user
      end

      opts.on("--identity=IDENTITY", "Bootstrap SSH identity") do |identity|
        options.identity = identity
      end

      opts.on("--hostname=HOSTNAME", "URI for the Chef Server") do |hostname|
        options.hostname = hostname
      end

      opts.on("--amqp_password=PASSWORD", "Password for chef vhost in RabbitMQ") do |password|
        options.amqp_password = password
      end

      opts.on("--admin_password=PASSWORD", "Password for 'admin' user in Chef Server WebUI") do |password|
        options.admin_password = password
      end


      opts.separator("")
      opts.separator("Output Options:")

      opts.on("-v", "--[no-]verbose", "Verbose output") do |verbose|
        options.log_level = (verbose ? :debug : :info)
      end

      opts.on("-l", "--log=OUTPUT", "Logging output") do |log|
        options.logger = case log.upcase.strip
        when "STDOUT"
          STDOUT
        when "STDERR"
          STRERR
        else
          log
        end
      end


      opts.separator("")
      opts.separator("General Options:")

      opts.on_tail("-V", "--version", "Show version") do
        puts "boot v#{Jumpkick::VERSION}"
        ::Kernel.exit
      end

      opts.on_tail("-h", "--help", "Show help") do
        puts opts
        ::Kernel.exit
      end
    end

    begin
      opts.parse!(args)

      if !(missing = mandatory.select{|param| options.send(param).nil? }).empty?
        puts "Missing option#{missing.size > 1 ? "s" : ""}: #{missing.join(", ")}"
        puts opts
        ::Kernel.exit
      end

    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts $!.to_s.capitalize
      puts opts
      ::Kernel.exit
    end

    options
  end

end
