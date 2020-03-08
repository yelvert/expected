# frozen_string_literal: true

module Expected
  RSpec.describe self do
    it {
      is_expected.to(
        have_constant(:VERSION).
          with_value([
            Version::MAJOR,
            Version::MINOR,
            Version::PATCH,
          ].join('.'))
      )
    }
  end

end
