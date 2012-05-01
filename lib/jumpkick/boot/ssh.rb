require "jumpkick/boot"

class Jumpkick::Boot::Ssh < Jumpkick::Boot

  banner "boot ssh QUERY COMMAND (options)"

  option :concurrency,
    :short => "-C NUM",
    :long => "--concurrency NUM",
    :description => "The number of concurrent connections.",
    :default => nil,
    :proc => lambda { |o| o.to_i }

  def run
  end

end
