Object.__send__(:remove_const, :VERSION) if defined?(VERSION)                    # because Ruby 1.8~ gets in the way

class TracePoint

  #
  def self.__DIR__
    File.dirname(__FILE__)    
  end

  #
  def self.const_missing(name)
    name = name.to_s.downcase
    require 'yaml' unless defined?(::YAML)
    @package ||= YAML.load(File.new(__DIR__ + '/package.yml'))
    @profile ||= YAML.load(File.new(__DIR__ + '/profile.yml'))
    @package[name] || @profile[name]
  end

end

