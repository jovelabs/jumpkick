require "jumpkick/version"
require "mixlib/cli"
require "jumpkick/mixin/convert_to_class_name"
require "jumpkick/boot/core/subcommand_loader"
require "jumpkick/boot/core/ui"

class Jumpkick
  class Boot

    include Mixlib::CLI
    extend Jumpkick::Mixin::ConvertToClassName

    attr_accessor :name_args
    attr_accessor :ui

    def self.ui
      @ui ||= Jumpkick::Boot::UI.new(STDOUT, STDERR, STDIN, {})
    end

    def self.msg(msg="")
      ui.msg(msg)
    end

    def self.reset_subcommands!
      @@subcommands = {}
      @subcommands_by_category = nil
    end

    def self.inherited(subclass)
      unless subclass.unnamed?
        subcommands[subclass.snake_case_name] = subclass
      end
    end

    def self.category(new_category)
      @category = new_category
    end

    def self.subcommand_category
      @category || snake_case_name.split('_').first unless unnamed?
    end

    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end

    def self.common_name
      snake_case_name.split('_').join(' ')
    end

    # Does this class have a name? (Classes created via Class.new don't)
    def self.unnamed?
      name.nil? || name.empty?
    end

    def self.subcommand_loader
      @subcommand_loader ||= Boot::SubcommandLoader.new(jumpkick_config_dir)
    end

    def self.load_commands
      @commands_loaded ||= subcommand_loader.load_commands
    end

    def self.subcommands
      @@subcommands ||= {}
    end

    def self.subcommands_by_category
      unless @subcommands_by_category
        @subcommands_by_category = Hash.new { |hash, key| hash[key] = [] }
        subcommands.each do |snake_cased, klass|
          @subcommands_by_category[klass.subcommand_category] << snake_cased
        end
      end
      @subcommands_by_category
    end


    def self.list_commands(preferred_category=nil)
      load_commands

      category_desc = preferred_category ? preferred_category + " " : ''
      msg "Available #{category_desc}subcommands: (for details, boot SUB-COMMAND --help)\n\n"

      if preferred_category && subcommands_by_category.key?(preferred_category)
        commands_to_show = {preferred_category => subcommands_by_category[preferred_category]}
      else
        commands_to_show = subcommands_by_category
      end

      commands_to_show.sort.each do |category, commands|
        next if category =~ /deprecated/i
        msg "** #{category.upcase} COMMANDS **"
        commands.each do |command|
          msg subcommands[command].banner if subcommands[command]
        end
        msg
      end
    end

    def self.run(args, options={})
      load_commands
      subcommand_class = subcommand_class_from(args)
      subcommand_class.options = options.merge!(subcommand_class.options)
      subcommand_class.load_deps
      instance = subcommand_class.new(args)
      instance.configure_chef
      instance.run_with_pretty_exceptions
    end

    def self.guess_category(args)
      category_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }
      category_words.map! {|w| w.split('-')}.flatten!
      matching_category = nil
      while (!matching_category) && (!category_words.empty?)
        candidate_category = category_words.join(' ')
        matching_category = candidate_category if subcommands_by_category.key?(candidate_category)
        matching_category || category_words.pop
      end
      matching_category
    end

    def self.subcommand_class_from(args)
      command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }

      subcommand_class = nil

      while ( !subcommand_class ) && ( !command_words.empty? )
        snake_case_class_name = command_words.join("_")
        unless subcommand_class = subcommands[snake_case_class_name]
          command_words.pop
        end
      end
      # see if we got the command as e.g., knife node-list
      subcommand_class ||= subcommands[args.first.gsub('-', '_')]
      subcommand_class || subcommand_not_found!(args)
    end

    def self.deps(&block)
      @dependency_loader = block
    end

    def self.load_deps
      @dependency_loader && @dependency_loader.call
    end

    private

    OFFICIAL_PLUGINS = %w[ec2 rackspace windows openstack terremark bluebox]

    # :nodoc:
    # Error out and print usage. probably becuase the arguments given by the
    # user could not be resolved to a subcommand.
    def self.subcommand_not_found!(args)
      ui.fatal("Cannot find sub command for: '#{args.join(' ')}'")

      if category_commands = guess_category(args)
        list_commands(category_commands)
      elsif missing_plugin = ( OFFICIAL_PLUGINS.find {|plugin| plugin == args[0]} )
        ui.info("The #{missing_plugin} commands were moved to plugins in Chef 0.10")
        ui.info("You can install the plugin with `(sudo) gem install knife-#{missing_plugin}")
      else
        list_commands
      end

      exit 10
    end

    @@jumpkick_config_dir = nil

    # search upward from current_dir until .chef directory is found
    def self.jumpkick_config_dir
      if @@jumpkick_config_dir.nil? # share this with subclasses
        @@jumpkick_config_dir = false
        full_path = Dir.pwd.split(File::SEPARATOR)
        (full_path.length - 1).downto(0) do |i|
          candidate_directory = File.join(full_path[0..i] + [".chef" ])
          if File.exist?(candidate_directory) && File.directory?(candidate_directory)
            @@jumpkick_config_dir = candidate_directory
            break
          end
        end
      end
      @@jumpkick_config_dir
    end

    public

    # Create a new instance of the current class configured for the given
    # arguments and options
    def initialize(argv=[])
      super() # having to call super in initialize is the most annoying anti-pattern :(
      @ui = Jumpkick::Boot::UI.new(STDOUT, STDERR, STDIN, config)

      command_name_words = self.class.snake_case_name.split('_')

      # Mixlib::CLI ignores the embedded name_args
      @name_args = parse_options(argv)
      @name_args.delete(command_name_words.join('-'))
      @name_args.reject! { |name_arg| command_name_words.delete(name_arg) }

      # knife node run_list add requires that we have extra logic to handle
      # the case that command name words could be joined by an underscore :/
      command_name_words = command_name_words.join('_')
      @name_args.reject! { |name_arg| command_name_words == name_arg }

      if config[:help]
        msg opt_parser
        exit 1
      end
    end

    def parse_options(args)
      super
    rescue OptionParser::InvalidOption => e
      puts "Error: " + e.to_s
      show_usage
      exit(1)
    end

  end
end
