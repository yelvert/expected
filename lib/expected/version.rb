# frozen_string_literal: true

module Expected

  # Contains version information
  module Version
    MAJOR = 1
    MINOR = 1
    PATCH = 2

  end

  VERSION = [
    Version::MAJOR,
    Version::MINOR,
    Version::PATCH,
  ].join('.').freeze

end
