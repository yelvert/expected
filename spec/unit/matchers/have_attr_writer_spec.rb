# frozen_string_literal: true

module Expected
  module Matchers
    RSpec.describe HaveAttrWriterMatcher do
      shared_examples :have_attr_writer do |good, bad|
        context "valid #{good}" do
          it { is_expected.to have_attr_writer(good) }
          it {
            expect { is_expected.not_to have_attr_writer(good) }.to(
              fail_with_message("Did not expect <#{subject}> to have attr_writer `#{good}`")
            )
          }
        end

        context "missing #{bad}" do
          it { is_expected.not_to have_attr_writer(bad) }
          it {
            expect { is_expected.to have_attr_writer(bad) }.to(
              fail_with_message("Expected <#{subject}> to have attr_writer `#{bad}` (no method `#{bad}=`)")
            )
          }
        end
      end

      describe :have_attr_writer do
        describe 'subject is a module' do
          subject do
            Module.new do
              class << self
                attr_writer :good
              end
            end
          end

          it_behaves_like :have_attr_writer, :good, :bad
        end

        describe 'subject is a class' do
          subject do
            Class.new do
              attr_writer :good
            end
          end

          it_behaves_like :have_attr_writer, :good, :bad
        end

        describe 'subject is an instance' do
          subject do
            Class.new do
              attr_writer :good
            end.new
          end

          it_behaves_like :have_attr_writer, :good, :bad
        end
      end

      subject { described_class.new(random_attribute_name) }

      describe '#initialize(attribute)' do
        it 'should set the attribute' do
          attribute = random_attribute_name
          expect(described_class.new(attribute).attribute).to be(attribute)
        end

        it 'should raise an error if the attribute is not a String or Symbol' do
          attribute = double(:attribute)
          expect(attribute).to receive(:is_a?).with(String).and_return(false)
          expect(attribute).to receive(:is_a?).with(Symbol).and_return(false)
          expect { described_class.new(attribute) }.to raise_error(/attribute must be a String or Symbol/)
        end
      end

      describe '#matches?(subject)' do
        checks = %i[ method? sets_correct_value? ]
        let(:matches_subject_attribute) { subject.attribute }
        let(:matches_subject) do
          c = Class.new
          c.send(:attr_writer, matches_subject_attribute)
          c.new
        end

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
        it 'should have the name of the attribute' do
          expect(subject.description).to eql("have_attr_writer: `#{subject.attribute}`")
        end
      end

      describe '#subject=' do
        it 'should set subject to the argument if it is a class' do
          klass = Class.new
          subject.send(:subject=, klass)
          expect(subject.instance_variable_get(:@original_subject)).to be(klass)
          expect(subject.subject).to be_a(klass)
        end

        it 'should set subject to the argument if it is a module' do
          mod = Module.new
          subject.send(:subject=, mod)
          expect(subject.instance_variable_get(:@original_subject)).to be(mod)
          expect(subject.subject).to be(mod)
        end

        it 'should set subject to the arguments class if it is an instance' do
          klass = Class.new
          instance = klass.new
          subject.send(:subject=, instance)
          expect(subject.subject).to be(instance)
        end
      end

      describe "#attribute_ivar" do
        it 'should return an instance variable name for the attribute' do
          expect(subject.send(:attribute_ivar)).to be(:"@#{subject.attribute}")
        end
      end

      describe '#method_name' do
        it 'should return a method name for the setter of the attribute' do
          expect(subject.send(:method_name)).to be(:"#{subject.attribute}=")
        end
      end

      describe '#method?' do
        let(:matches_subject) { double(:matches_subject) }
        before(:example) { subject.send(:subject=, matches_subject) }

        it 'should return true if the subject a method for the attribute' do
          expect(matches_subject).to receive(:respond_to?).with(subject.send(:method_name)).and_return(true)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:method?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set the failure message if the subject does not have a method for the attribute' do
          expect(matches_subject).to receive(:respond_to?).with(subject.send(:method_name)).and_return(false)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:method?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to eql("no method `#{subject.send(:method_name)}`")
        end
      end

      describe '#sets_correct_value?' do
        let(:matches_subject) { double(:matches_subject) }
        before(:example) { subject.send(:subject=, matches_subject) }

        it 'should return true if the attribute method sets the instance variable' do
          expect(matches_subject).to receive(subject.send(:method_name)) {|arg| matches_subject.instance_variable_set(subject.send(:attribute_ivar), arg) }
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:sets_correct_value?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set the failure message if the attribute method does not set the instance variable' do
          expect(matches_subject).to receive(subject.send(:method_name)) { double(:bad) }
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:sets_correct_value?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to(
            eql("method `#{subject.send(:method_name)}` did not set the value of #{subject.send(:attribute_ivar)}")
          )
        end
      end

      describe '#expectation' do
        let(:matches_subject) { double(:subject) }
        before(:example) { subject.send(:subject=, matches_subject) }

        it 'should have the name of the attribute' do
          expect(subject.send(:expectation)).to eql("<#{matches_subject}> to have attr_writer `#{subject.attribute}`")
        end
      end

      def random_attribute_name
        Faker::Crypto.sha256.remove(/\d/).downcase.to_sym
      end
    end

  end
end
