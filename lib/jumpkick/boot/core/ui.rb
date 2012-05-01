class Jumpkick
  class Boot

    class UI

      def initialize(stdout, stderr, stdin, config)
        @stdout, @stderr, @stdin, @config = stdout, stderr, stdin, config
      end

      def highline
        @highline ||= begin
          require 'highline'
          HighLine.new
        end
      end

      def msg(message)
        @stdout.puts(message)
      end

      alias :info :msg

      # Prints a msg to stderr. Used for warn, error, and fatal.
      def err(message)
        @stderr.puts message
      end

      # Print a warning message
      def warn(message)
        err("#{color('WARNING:', :yellow, :bold)} #{message}")
      end

      # Print an error message
      def error(message)
        err("#{color('ERROR:', :red, :bold)} #{message}")
      end

      # Print a message describing a fatal error.
      def fatal(message)
        err("#{color('FATAL:', :red, :bold)} #{message}")
      end

      def color(string, *colors)
        if color?
          highline.color(string, *colors)
        else
          string
        end
      end

      # Should colored output be used? For output to a terminal, this is
      # determined by the value of `config[:color]`. When output is not to a
      # terminal, colored output is never used
      def color?
        Chef::Config[:color] && @stdout.tty?
      end

      def ask(*args, &block)
        highline.ask(*args, &block)
      end

      def list(*args)
        highline.list(*args)
      end

    end

  end
end
