# frozen_string_literal: true

module Expected
  RSpec.describe self do
    it {
      is_expected.to(
        have_constant(:VERSION).
          with_value([
            Version::MAJOR,
            Version::MAJOR,
            Version::MAJOR,
          ].join('.'))
      )
    }
  end

end
