# frozen_string_literal: true

module Expected

  # Contains version information
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 0

  end

  VERSION = [
    Version::MAJOR,
    Version::MINOR,
    Version::PATCH,
  ].join('.').freeze

end
