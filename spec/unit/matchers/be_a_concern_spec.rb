# frozen_string_literal: true

module Expected
  module Matchers
    RSpec.describe BeAConcernMatcher do
      describe :be_a_concern do

        describe 'subject is an ActiveSupport::Concern' do
          subject { Module.new { extend ActiveSupport::Concern } }
          it { is_expected.to be_a_concern }
          it {
            expect { is_expected.not_to be_a_concern }.to(
              fail_with_message("Did not expect <#{subject.inspect}> to be an ActiveSupport::Concern")
            )
          }
        end

        describe 'subject is not an ActiveSupport::Concern' do
          subject { Module.new }
          it { is_expected.not_to be_a_concern }
          it {
            expect { is_expected.to be_a_concern }.to(
              fail_with_message("Expected <#{subject.inspect}> to be an ActiveSupport::Concern")
            )
          }
        end
      end

      subject { described_class.new }

      it { is_expected.to have_attr_reader(:extend_module_matcher) }

      describe '#initialize' do
        it 'should set extend_module_matcher to a ExtendModuleMatcher' do
          expect(subject.extend_module_matcher).to be_a(ExtendModuleMatcher)
          expect(subject.extend_module_matcher.expected_module).to be(ActiveSupport::Concern)
        end
      end

      describe '#matches?(subject)' do
        let(:matches_subject) { Module.new }

        it 'should set the subject' do
          expect(subject).to receive(:subject=).with(matches_subject).and_call_original
          subject.matches?(matches_subject)
        end

        it 'should return true if the subject is an ActiveSupport::Concern' do
          expect(subject.extend_module_matcher).to receive(:matches?).with(matches_subject).and_return(true)
          expect(subject.matches?(matches_subject)).to be_truthy
        end

        it 'should return false if the subject is not an ActiveSupport::Concern' do
          expect(subject.extend_module_matcher).to receive(:matches?).with(matches_subject).and_return(false)
          expect(subject.matches?(matches_subject)).to be_falsey
        end
      end

      describe '#failure_message' do
        it 'should return a string with the expectation and failure in it' do
          expectation = Faker::Crypto.sha256
          expect(subject).to receive(:expectation).and_return(expectation)
          expect(subject.failure_message).to eql("Expected #{expectation}")
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
        it 'should have a description' do
          expect(subject.description).to eql('be_a_concern')
        end
      end

      describe '#subject=' do
        it 'should set subject to the argument if it is a Module' do
          mod = Module.new
          subject.send(:subject=, mod)
          expect(subject.subject).to be(mod)
        end

        context 'should raise InvalidSubjectError if subject is not a Module' do
          [ Class.new, Class.new.new, 'test', 123 ].each do |sub|
            it sub do
              expect { subject.send(:subject=, sub) }.to(
                raise_error(
                  "The subject for BeAConcernMatcher must be a Module, but was: `#{sub.inspect}`"
                )
              )
            end
          end
        end
      end

      describe '#expectation' do
        it 'should have the expected ancestor' do
          allow(subject).to receive(:subject).and_return(double(:subject))
          expect(subject.send(:expectation)).to(
            eql("<#{subject.subject.inspect}> to be an ActiveSupport::Concern")
          )
        end
      end
    end

  end
end
