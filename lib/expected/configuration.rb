# frozen_string_literal: true

# :nodoc:
module Expected
  class << self

    # Configure the library
    # @yield [Configuration]
    def configure
      yield configuration
      return unless defined?(::RSpec)
      ::RSpec.configure do |config|
        config.include(Matchers)
      end
      configuration
    end

    # Memoized {Configuration}
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

  end

  # Configuration class
  class Configuration
  end

end
