class Jumpkick::Config

  def initalize
    knife_config = File.join(Dir.pwd, "..", ".chef", "knife.rb")
    if File.exists?(knife_config)
      ::Chef::Config.from_file(knife_config)
      @config = ::Chef::Config
      verify_configuration
      return @config
    else
      raise(Jumpkick::Exceptions::Configuration, "Could not load '#{knife_config}}'!")
    end
  end

  def [](key)
    @config[key]
  end

  def []=(key, value)
    @config[key] = value
  end

  private

  def verify_configuration
    errors = []
    errors << verify_configration_orgname
    if (errors.compact.count > 0)
      raise(Jumpkick::Exceptions::Configuration, errors.join("\n"))
    end
  end

  def verify_configration_orgname
    nil
  end

end
