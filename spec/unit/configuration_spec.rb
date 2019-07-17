# frozen_string_literal: true

module Expected
  RSpec.describe self do
    describe '.configure' do
      it 'should yield a Configuration' do
        expect { |x| described_class.configure(&x) }.to yield_with_args(described_class.configuration)
      end
    end

    describe '.configuration' do
      it 'should return a Configuration' do
        expect(described_class.configuration).to be_a(Configuration)
      end

      it 'should memoize' do
        expect(described_class.configuration).to be(described_class.configuration)
      end
    end
  end

  RSpec.describe Configuration do
  end

end
