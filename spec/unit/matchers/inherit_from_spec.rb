# frozen_string_literal: true

module Expected
  module Matchers
    RSpec.describe InheritFromMatcher do
      shared_examples :inherit_from do |expected_subject, good, bad|
        good.each do |klass|
          it { is_expected.to inherit_from(klass) }
          it {
            expect { is_expected.not_to inherit_from(klass) }.to(
              fail_with_message("Did not expect <#{expected_subject.inspect}> to inherit from <#{klass.inspect}>")
            )
          }
        end
        bad.each do |klass|
          it { is_expected.not_to inherit_from(klass) }
          it {
            expect { is_expected.to inherit_from(klass) }.to(
              fail_with_message("Expected <#{expected_subject.inspect}> to inherit from <#{klass.inspect}>")
            )
          }
        end
      end

      describe :inherit_from do
        ancestor_mod = Module.new { @name = :ancestor_mod }
        included_mod = Module.new { @name = :included_mod }
        extended_mod = Module.new { @name = :extended_mod }
        ancestor_class = Class.new do
          include ancestor_mod
        end
        parent_class = Class.new(ancestor_class)
        klass = Class.new(parent_class) do
          include included_mod
          extend extended_mod
        end

        describe 'subject is a Class' do
          subject { klass }

          it_behaves_like(
            :inherit_from,
            klass,
            [ Object, Kernel, ancestor_class, parent_class, ancestor_mod, included_mod ],
            [ Module, Class.new, Module.new, extended_mod ]
          )
        end

        describe 'subject is an instance' do
          subject { klass.new }

          it_behaves_like(
            :inherit_from,
            klass,
            [ Object, Kernel, ancestor_class, parent_class, ancestor_mod, included_mod ],
            [ Module, Class.new, Module.new, extended_mod ]
          )
        end
      end

      let(:expected_ancestor) { Class.new }
      subject { described_class.new(expected_ancestor) }

      describe '#initialize(expected_ancestor)' do
        it 'should set the expected_ancestor' do
          expect(subject.expected_ancestor).to be(expected_ancestor)
        end
      end

      describe '#matches?(subject)' do
        let(:matches_subject) { Class.new }

        it 'should set the subject' do
          expect(subject).to receive(:subject=).with(matches_subject).and_call_original
          subject.matches?(matches_subject)
        end

        it 'should return true if the subjects ancestors include the expected_ancestor' do
          ancestors = double
          expect(matches_subject).to receive(:ancestors).and_return(ancestors)
          expect(ancestors).to receive(:include?).with(expected_ancestor).and_return(true)
          expect(subject.matches?(matches_subject)).to be_truthy
        end

        it 'should return false if the subjects ancestors does not include the expected_ancestor' do
          ancestors = double
          expect(matches_subject).to receive(:ancestors).and_return(ancestors)
          expect(ancestors).to receive(:include?).with(expected_ancestor).and_return(false)
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
        it 'should have the expected_ancestor' do
          expect(subject.description).to eql("inherit_from: <#{subject.expected_ancestor.inspect}>")
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

      describe '#expectation' do
        it 'should have the expected ancestor' do
          allow(subject).to receive(:subject).and_return(double(:subject))
          expect(subject.send(:expectation)).to(
            eql("<#{subject.subject.inspect}> to inherit from <#{expected_ancestor.inspect}>")
          )
        end
      end
    end

  end
end
