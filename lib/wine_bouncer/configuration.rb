module WineBouncer

  class << self
    attr_accessor :configuration
  end

  class Configuration

    attr_accessor :auth_strategy
    attr_accessor :defined_resource_owner

    def auth_strategy=(strategy)
      @auth_strategy= strategy
    end

    def auth_strategy
      @auth_strategy || :default
    end

    def require_strategies
      require "wine_bouncer/auth_strategies/#{auth_strategy}"
    end

    def define_resource_owner &block
      fail(ArgumentError, 'define_resource_owner expects a block in the configuration') unless block_given?
      @defined_resource_owner = block
    end

    def defined_resource_owner
      fail(Errors::UnconfiguredError, 'Please define define_resource_owner to configure the resource owner') unless @defined_resource_owner
      @defined_resource_owner
    end
  end

   def self.configuration
    @configuration || fail(Errors::UnconfiguredError.new)
  end

  def self.configuration=(config)
    @configuration= config
    @configuration.require_strategies
  end

  ###
  # Configure block.
  # Requires all strategy specific files.
  ###
  def self.configure
    yield(config)
    config.require_strategies
    config
  end

  private

  ###
  # Returns a new configuration or existing one.
  ###
  def self.config
    @configuration ||= Configuration.new
  end
end
