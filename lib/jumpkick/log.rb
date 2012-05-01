require "mixlib/log"

class Jumpkick::Log
  extend Mixlib::Log

  init

  class Formatter
    def self.show_time(*args)
      Mixlib::Log::Formatter.show_time = *args
    end
  end

end
