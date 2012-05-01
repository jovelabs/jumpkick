require 'chef/version'
class Jumpkick
  class Boot
    class SubcommandLoader

      JUMPKICK_FILE_IN_GEM = /chef-[\d]+\.[\d]+\.[\d]+/
      CURRENT_JUMPKICK_GEM = /chef-#{Regexp.escape(Jumpkick::VERSION)}/

      attr_reader :jumpkick_config_dir
      attr_reader :env

      def initialize(jumpkick_config_dir, env=ENV)
        @jumpkick_config_dir, @env = jumpkick_config_dir, env
        @forced_activate = {}
      end

      # Load all the sub-commands
      def load_commands
        subcommand_files.each { |subcommand| Kernel.load subcommand }
        true
      end

      # Returns an Array of paths to boot commands located in jumpkick_config_dir/plugins/boot/
      # and ~/.chef/plugins/boot/
      def site_subcommands
        user_specific_files = []

        if jumpkick_config_dir
          user_specific_files.concat Dir.glob(File.expand_path("plugins/boot/*.rb", jumpkick_config_dir))
        end

        # finally search ~/.chef/plugins/boot/*.rb
        user_specific_files.concat Dir.glob(File.join(env['HOME'], '.chef', 'plugins', 'boot', '*.rb')) if env['HOME']

        user_specific_files
      end

      # Returns a Hash of paths to boot commands built-in to chef, or installed via gem.
      # If rubygems is not installed, falls back to globbing the boot directory.
      # The Hash is of the form {"relative/path" => "/absolute/path"}
      #--
      # Note: the "right" way to load the plugins is to require the relative path, i.e.,
      #   require 'chef/boot/command'
      # but we're getting frustrated by bugs at every turn, and it's slow besides. So
      # subcommand loader has been modified to load the plugins by using Kernel.load
      # with the absolute path.
      def gem_and_builtin_subcommands
        # search all gems for chef/boot/*.rb
        require 'rubygems'
        find_subcommands_via_rubygems
      rescue LoadError
        find_subcommands_via_dirglob
      end

      def subcommand_files
        @subcommand_files ||= (gem_and_builtin_subcommands.values + site_subcommands).flatten.uniq
      end

      def find_subcommands_via_dirglob
        # The "require paths" of the core boot subcommands bundled with chef
        files = Dir[File.expand_path('../../../boot/*.rb', __FILE__)]
        subcommand_files = {}
        files.each do |boot_file|
          rel_path = boot_file[/#{JUMPKICK_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1]
          subcommand_files[rel_path] = boot_file
        end
        subcommand_files
      end

      def find_subcommands_via_rubygems
        files = Gem.find_files 'jumpkick/boot/*.rb'
        files.reject! {|f| from_old_gem?(f) }
        subcommand_files = {}
        files.each do |file|
          rel_path = file[/(#{Regexp.escape File.join('jumpkick', 'boot', '')}.*)\.rb/, 1]
          subcommand_files[rel_path] = file
        end

        subcommand_files.merge(find_subcommands_via_dirglob)
      end

      private

      # wow, this is a sad hack :(
      # Gem.find_files finds files in all versions of a gem, which
      # means that if chef 0.10 and 0.9.x are installed, we'll try to
      # require, e.g., chef/boot/ec2_server_create, which will cause
      # a gem activation error. So remove files from older chef gems.
      def from_old_gem?(path)
        path =~ JUMPKICK_FILE_IN_GEM && path !~ CURRENT_JUMPKICK_GEM
      end
    end
  end
end
