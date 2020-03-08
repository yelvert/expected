# frozen_string_literal: true

module Expected
  module Matchers
    RSpec.describe HaveConstantMatcher do
      shared_examples :have_constant do |constants|
        constants.each do |constant|
          context constant do
            let(:actual_value) { subject.const_get(constant) }
            let(:actual_type) { actual_value.class }
            it { is_expected.to have_constant(constant) }
            it { is_expected.to have_constant(constant).of_type(actual_type) }
            it { is_expected.to have_constant(constant).with_value(actual_value) }
            it { is_expected.to have_constant(constant).of_type(actual_type).with_value(actual_value) }
            it {
              expected_type = Class.new
              expect { is_expected.to have_constant(constant).of_type(expected_type) }.to(
                fail_with_message(
                  "Expected <#{subject}> to have a constant named #{constant}" \
                  " with a type of <#{expected_type}>" \
                  " (type was <#{actual_type}>)"
                )
              )
            }
            it {
              expected_value = double(:expected_value)
              expect { is_expected.to have_constant(constant).with_value(expected_value) }.to(
                fail_with_message(
                  "Expected <#{subject}> to have a constant named #{constant}" \
                  " with a value of #{expected_value.inspect}" \
                  " (value was #{actual_value.inspect})"
                )
              )
            }
            it {
              expected_type = Class.new
              expected_value = double(:expected_value)
              expect { is_expected.to have_constant(constant).of_type(expected_type).with_value(expected_value) }.to(
                fail_with_message(
                  "Expected <#{subject}> to have a constant named #{constant}" \
                  " with a type of <#{expected_type}>" \
                  " with a value of #{expected_value.inspect}" \
                  " (type was <#{actual_type}>)"
                )
              )
            }
            it {
              expected_type = Class.new
              expected_value = actual_value
              expect { is_expected.to have_constant(constant).of_type(expected_type).with_value(expected_value) }.to(
                fail_with_message(
                  "Expected <#{subject}> to have a constant named #{constant}" \
                  " with a type of <#{expected_type}>" \
                  " with a value of #{expected_value.inspect}" \
                  " (type was <#{actual_type}>)"
                )
              )
            }
            it {
              expected_value = double(:expected_value)
              expect { is_expected.to have_constant(constant).of_type(actual_type).with_value(expected_value) }.to(
                fail_with_message(
                  "Expected <#{subject}> to have a constant named #{constant}" \
                  " with a type of <#{actual_type}>" \
                  " with a value of #{expected_value.inspect}" \
                  " (value was #{actual_value.inspect})"
                )
              )
            }
          end
        end

        context '(missing constant)' do
          let(:constant) { random_const_name }
          let(:expected_type) { Class.new }
          let(:expected_value) { double(:expected_value) }
          it {
            expect { is_expected.to have_constant(constant) }.to(
              fail_with_message("Expected <#{subject}> to have a constant named #{constant} (missing constant)")
            )
          }
          it {
            expect { is_expected.to have_constant(constant).of_type(expected_type) }.to(
              fail_with_message(
                "Expected <#{subject}> to have a constant named #{constant}" \
                " with a type of <#{expected_type}> (missing constant)"
              )
            )
          }
          it {
            expect { is_expected.to have_constant(constant).with_value(expected_value) }.to(
              fail_with_message(
                "Expected <#{subject}> to have a constant named #{constant}" \
                " with a value of #{expected_value.inspect} (missing constant)"
              )
            )
          }
          it {
            expect { is_expected.to have_constant(constant).of_type(expected_type).with_value(expected_value) }.to(
              fail_with_message(
                "Expected <#{subject}> to have a constant named #{constant}" \
                " with a type of <#{expected_type}>" \
                " with a value of #{expected_value.inspect}" \
                ' (missing constant)'
              )
            )
          }
        end
      end

      describe :have_constant do
        describe 'subject is a module' do
          subject do
            Module.new do
              self::FOO = Class.new.new
              self::BAR = Class.new.new
            end
          end

          it_behaves_like :have_constant, %i[ FOO BAR ]
        end

        describe 'subject is a class' do
          subject do
            Class.new do
              self::FOO = Class.new.new
              self::BAR = Class.new.new
            end
          end

          it_behaves_like :have_constant, %i[ FOO BAR ]
        end

        describe 'subject is an instance' do
          subject do
            Module.new do
              self::FOO = Class.new.new
              self::BAR = Class.new.new
            end
          end

          it_behaves_like :have_constant, %i[ FOO BAR ]
        end
      end

      subject { described_class.new(random_const_name) }

      describe '#initialize(name)' do
        it 'should set the name' do
          name = random_const_name
          expect(described_class.new(name).name).to be(name)
        end

        it 'should raise an error if the name is not a String or Symbol' do
          name = double(:name)
          expect(name).to receive(:is_a?).with(String).and_return(false)
          expect(name).to receive(:is_a?).with(Symbol).and_return(false)
          expect { described_class.new(name) }.to raise_error(/constant name must be a String or Symbol/)
        end
      end

      describe '#with_value(value)' do
        let(:value) { double(:type) }

        it 'should set the value option' do
          expect(subject.send(:options)).not_to include(:value)
          subject.with_value(value)
          expect(subject.send(:options)).to include(value: value)
        end

        it 'should return self' do
          expect(subject.with_value(value)).to be(subject)
        end
      end

      describe '#of_value(type)' do
        let(:type) { double(:type) }

        it 'should set the value option' do
          expect(subject.send(:options)).not_to include(:type)
          subject.of_type(type)
          expect(subject.send(:options)).to include(type: type)
        end

        it 'should return self' do
          expect(subject.of_type(type)).to be(subject)
        end
      end

      describe '#matches?(subject)' do
        checks = %i[ constant_exists? correct_type? correct_value? ]
        let(:matches_subject_const_name) { subject.name }
        let(:matches_subject) { Object.const_set(matches_subject_const_name, Class.new).new }

        after(:example) { Object.send(:remove_const, matches_subject_const_name) }

        it 'should set the subject' do
          expect(subject).to receive(:subject=).with(matches_subject).and_call_original
          subject.matches?(matches_subject)
        end

        it 'should return true if all checks pass' do
          checks.each do |check|
            expect(subject).to receive(check).and_return(true)
          end
          expect(subject.matches?(matches_subject)).to be_truthy
        end

        checks.each_index do |failing_check|
          it "should return false the #{checks[failing_check]} check fails" do
            if failing_check > 0
              checks.to(failing_check - 1).each do |passing_check|
                expect(subject).to receive(passing_check).and_return(true)
              end
            end
            expect(subject).to receive(checks[failing_check]).and_return(false)
            expect(subject.matches?(matches_subject)).to be_falsy
          end
        end
      end

      describe '#failure_message' do
        it 'should return a string with the expectation and failure in it' do
          expectation = Faker::Crypto.sha256
          failure = Faker::Crypto.sha256
          expect(subject).to receive(:expectation).and_return(expectation)
          subject.instance_variable_set(:@failure, failure)
          expect(subject.failure_message).to eql("Expected #{expectation} (#{failure})")
        end
      end

      describe '#failure_message_when_negated' do
        it 'should return a string with the expectation in it' do
          expectation = Faker::Crypto.sha256
          expect(subject).to receive(:expectation).and_return(expectation)
          expect(subject.failure_message_when_negated).to eql("Did not expect #{expectation}")
        end
      end

      describe '#description' do
        context 'no modifiers' do
          it 'should have the name of the constant' do
            expect(subject.description).to eql("have_constant: #{subject.name}")
          end
        end

        context 'of_type' do
          let(:type) { Faker::Crypto.sha256 }
          before(:example) { subject.of_type(type) }

          it 'should have the expected type of the constant' do
            expect(subject.description).to eql("have_constant: #{subject.name} of_type => #{type.inspect}")
          end
        end

        context 'with_value' do
          let(:value) { Faker::Crypto.sha256 }
          before(:example) { subject.with_value(value) }

          it 'should have the expected value of the constant' do
            expect(subject.description).to eql("have_constant: #{subject.name} with_value => #{value.inspect}")
          end
        end

        context 'of_type with_value' do
          let(:type) { Faker::Crypto.sha256 }
          let(:value) { Faker::Crypto.sha256 }
          before(:example) { subject.of_type(type).with_value(value) }

          it 'should have the expected type and expected value of the constant' do
            expect(subject.description).to(
              eql("have_constant: #{subject.name} of_type => #{type.inspect} with_value => #{value.inspect}")
            )
          end
        end
      end

      describe '#options' do
        it 'should be a hash with indifferent access' do
          expect(subject.send(:options)).to be_a(ActiveSupport::HashWithIndifferentAccess)
        end

        it 'should memoize' do
          expect(subject.send(:options)).to be(subject.send(:options))
        end
      end

      describe '#subject=' do
        it 'should set subject to the argument if it is a class' do
          klass = Class.new
          subject.send(:subject=, klass)
          expect(subject.subject).to be(klass)
        end

        it 'should set subject to the argument if it is a module' do
          mod = Module.new
          subject.send(:subject=, mod)
          expect(subject.subject).to be(mod)
        end

        it 'should set subject to the arguments class if it is an instance' do
          klass = Class.new
          subject.send(:subject=, klass.new)
          expect(subject.subject).to be(klass)
        end
      end

      describe '#constant_exists?' do
        let(:matches_subject) { double(:matches_subject) }
        before(:example) { subject.instance_variable_set(:@subject, matches_subject) }

        it 'should return true if the subject has the constant defined' do
          expect(matches_subject).to receive(:const_defined?).with(subject.name).and_return(true)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:constant_exists?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set the failure message if the subject does not have the constant defined' do
          expect(matches_subject).to receive(:const_defined?).with(subject.name).and_return(false)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:constant_exists?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to eql('missing constant')
        end
      end

      describe '#correct_type?' do
        it 'should return true if type should not be checked' do
          expect(subject.send(:options)).to eql({})
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:correct_type?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return true if the expected type matches the actual type' do
          klass = Class.new
          subj = Class.new
          subj.const_set(subject.name, klass.new)
          subject.send(:options)[:type] = klass
          subject.instance_variable_set(:@subject, subj)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:correct_type?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set the failure message if the expected type does not match the actual type' do
          expected = Class.new
          actual = Class.new
          subj = Class.new
          subj.const_set(subject.name, actual)
          subject.send(:options)[:type] = expected
          subject.instance_variable_set(:@subject, subj)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:correct_type?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to eql("type was <#{actual.class}>")
        end
      end

      describe '#correct_value?' do
        it 'should return true if value should not be checked' do
          expect(subject.send(:options)).to eql({})
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:correct_value?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return true if the expected value matches the actual value' do
          value = double("value: #{Faker::Crypto.sha256}")
          subj = Class.new
          subj.const_set(subject.name, value)
          subject.send(:options)[:value] = value
          subject.instance_variable_set(:@subject, subj)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:correct_value?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set the failure message if the expected value does not match the actual value' do
          expected = double("expected: #{Faker::Crypto.sha256}")
          actual = double("actual: #{Faker::Crypto.sha256}")
          subj = Class.new
          subj.const_set(subject.name, actual)
          subject.send(:options)[:value] = expected
          subject.instance_variable_set(:@subject, subj)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:correct_value?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to eql("value was #{actual.inspect}")
        end
      end

      describe '#expectation' do
        let(:matches_subject) { double(:subject) }
        before(:example) { allow(subject).to receive(:subject).and_return(matches_subject) }

        context 'no modifiers' do
          it 'should have the name of the constant' do
            expect(subject.send(:expectation)).to eql("<#{subject.subject}> to have a constant named #{subject.name}")
          end
        end

        context 'of_type' do
          let(:type) { Faker::Crypto.sha256 }
          before(:example) { subject.of_type(type) }

          it 'should have the expected type of the constant' do
            expect(subject.send(:expectation)).to(
              eql("<#{subject.subject}> to have a constant named #{subject.name} with a type of <#{type}>")
            )
          end
        end

        context 'with_value' do
          let(:value) { Faker::Crypto.sha256 }
          before(:example) { subject.with_value(value) }

          it 'should have the expected value of the constant' do
            expect(subject.send(:expectation)).to(
              eql("<#{subject.subject}> to have a constant named #{subject.name} with a value of #{value.inspect}")
            )
          end
        end

        context 'of_type with_value' do
          let(:type) { Faker::Crypto.sha256 }
          let(:value) { Faker::Crypto.sha256 }
          before(:example) { subject.of_type(type).with_value(value) }

          it 'should have the expected type and expected value of the constant' do
            expect(subject.send(:expectation)).to(
              eql("<#{subject.subject}> to have a constant named " \
                  "#{subject.name} with a type of <#{type}> with a value of #{value.inspect}")
            )
          end
        end
      end

      def random_const_name
        Faker::Crypto.sha256.remove(/\d/).upcase
      end
    end

  end
end
