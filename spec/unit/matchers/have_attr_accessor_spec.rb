# frozen_string_literal: true

module Expected
  module Matchers
    RSpec.describe HaveAttrAccessorMatcher do
      shared_examples :have_attr_accessor do |good, bad, missing_reader, missing_writer|
        context "valid #{good}" do
          it { is_expected.to have_attr_accessor(good) }
          it {
            expect { is_expected.not_to have_attr_accessor(good) }.to(
              fail_with_message("Did not expect <#{subject}> to have attr_accessor `#{good}`")
            )
          }
        end

        context "missing #{bad}" do
          it { is_expected.not_to have_attr_accessor(bad) }
          it {
            expect { is_expected.to have_attr_accessor(bad) }.to(
              fail_with_message("Expected <#{subject}> to have attr_accessor `#{bad}` (no method `#{bad}`)")
            )
          }
        end

        context "missing reader #{missing_reader}" do
          it { is_expected.not_to have_attr_accessor(missing_reader) }
          it {
            expect { is_expected.to have_attr_accessor(missing_reader) }.to(
              fail_with_message("Expected <#{subject}> to have attr_accessor `#{missing_reader}` (no method `#{missing_reader}`)")
            )
          }
        end

        context "missing writer #{missing_writer}" do
          it { is_expected.not_to have_attr_accessor(missing_writer) }
          it {
            expect { is_expected.to have_attr_accessor(missing_writer) }.to(
              fail_with_message("Expected <#{subject}> to have attr_accessor `#{missing_writer}` (no method `#{missing_writer}=`)")
            )
          }
        end
      end

      describe :have_attr_accessor do
        describe 'subject is a module' do
          subject do
            Module.new do
              class << self
                attr_accessor :good
                attr_writer :missing_reader
                attr_reader :missing_writer
              end
            end
          end

          it_behaves_like :have_attr_accessor, :good, :bad, :missing_reader, :missing_writer
        end

        describe 'subject is a class' do
          subject do
            Class.new do
              attr_accessor :good
              attr_writer :missing_reader
              attr_reader :missing_writer
            end
          end

          it_behaves_like :have_attr_accessor, :good, :bad, :missing_reader, :missing_writer
        end

        describe 'subject is an instance' do
          subject do
            Class.new do
              attr_accessor :good
              attr_writer :missing_reader
              attr_reader :missing_writer
            end.new
          end

          it_behaves_like :have_attr_accessor, :good, :bad, :missing_reader, :missing_writer
        end
      end

      subject { described_class.new(random_attribute_name) }

      describe '#initialize(attribute)' do
        it 'should set the attribute' do
          attribute = random_attribute_name
          expect(described_class.new(attribute).attribute).to be(attribute)
        end

        it 'should set has_attr_reader to a HaveAttrReaderMatcher' do
          expect(subject.has_attr_reader).to be_a(HaveAttrReaderMatcher)
          expect(subject.has_attr_reader.attribute).to be(subject.attribute)
        end

        it 'should set has_attr_writer to a HaveAttrWriterMatcher' do
          expect(subject.has_attr_writer).to be_a(HaveAttrWriterMatcher)
          expect(subject.has_attr_writer.attribute).to be(subject.attribute)
        end

        it 'should raise an error if the attribute is not a String or Symbol' do
          attribute = double(:attribute)
          expect(attribute).to receive(:is_a?).with(String).and_return(false)
          expect(attribute).to receive(:is_a?).with(Symbol).and_return(false)
          expect { described_class.new(attribute) }.to raise_error(/attribute must be a String or Symbol/)
        end
      end

      describe '#matches?(subject)' do
        checks = %i[ matches_attr_reader? matches_attr_writer? ]
        let(:matches_subject_attribute) { subject.attribute }
        let(:matches_subject) do
          c = Class.new
          c.send(:attr_accessor, matches_subject_attribute)
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
          expect(subject.description).to eql("have_attr_accessor: `#{subject.attribute}`")
        end
      end

      describe '#subject=' do
        it 'should set subject to the argument' do
          matches_subject = double(:matches_subject)
          subject.send(:subject=, matches_subject)
          expect(subject.instance_variable_get(:@subject)).to be(matches_subject)
          expect(subject.subject).to be(matches_subject)
        end
      end

      describe '#matches_attr_reader?' do
        let(:matches_subject) { double(:subject) }
        before(:example) { subject.send(:subject=, matches_subject) }

        it 'should return true if the has_attr_reader matches' do
          expect(subject.has_attr_reader).to receive(:matches?).with(matches_subject).and_return(true)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:matches_attr_reader?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set @failure to the has_attr_reader failure if the has_attr_reader does not match' do
          expect(subject.has_attr_reader).to receive(:matches?).with(matches_subject).and_return(false)
          failure = double(:failure)
          subject.has_attr_reader.instance_variable_set(:@failure, failure)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:matches_attr_reader?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to be(failure)
        end
      end

      describe '#matches_attr_writer?' do
        let(:matches_subject) { double(:subject) }
        before(:example) { subject.send(:subject=, matches_subject) }

        it 'should return true if the has_attr_writer matches' do
          expect(subject.has_attr_writer).to receive(:matches?).with(matches_subject).and_return(true)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:matches_attr_writer?)).to be_truthy
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
        end

        it 'should return false and set @failure to the has_attr_writer failure if the has_attr_writer does not match' do
          expect(subject.has_attr_writer).to receive(:matches?).with(matches_subject).and_return(false)
          failure = double(:failure)
          subject.has_attr_writer.instance_variable_set(:@failure, failure)
          expect(subject.instance_variable_defined?(:@failure)).to be_falsy
          expect(subject.send(:matches_attr_writer?)).to be_falsy
          expect(subject.instance_variable_get(:@failure)).to be(failure)
        end
      end

      describe '#expectation' do
        let(:matches_subject) { double(:subject) }
        before(:example) { subject.send(:subject=, matches_subject) }

        it 'should have the name of the attribute' do
          expect(subject.send(:expectation)).to eql("<#{matches_subject}> to have attr_accessor `#{subject.attribute}`")
        end
      end

      def random_attribute_name
        Faker::Crypto.sha256.remove(/\d/).downcase.to_sym
      end
    end

  end
end
