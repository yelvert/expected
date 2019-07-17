# frozen_string_literal: true

# :nodoc:
module Expected
  class << self
    # Configure the library
    # @yield [Configuration]
    def configure
      yield configuration
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
