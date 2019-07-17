# frozen_string_literal: true

module Expected
  RSpec.describe Version do
    %w[ MAJOR MINOR PATCH ].each do |level|
      it { is_expected.to have_constant(level).of_type(Integer) }
    end
  end

end
