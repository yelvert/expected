# frozen_string_literal: true

require 'expected/matchers/extend_module'

module Expected
  # :nodoc:
  module Matchers

    # Used to test inheritance
    # @return [BeAConcernMatcher]
    #
    # @example Test if the subject is an ActiveSupport::Concern
    #   it { is_expected.to be_a_concern }
    #
    def be_a_concern
      BeAConcernMatcher.new
    end

    # Class used by {#be_a_concern}
    class BeAConcernMatcher
      attr_reader :extend_module_matcher, :subject

      def initialize
        @extend_module_matcher = ExtendModuleMatcher.new(ActiveSupport::Concern)
      end

      # Run the test
      # @param subject The thing to test against
      # @return [True] If the test passes
      # @return [False] if the test fails
      def matches?(subject)
        self.subject = subject
        @extend_module_matcher.matches?(subject)
      end

      # @return [String]
      def failure_message
        "Expected #{expectation}"
      end

      # @return [String]
      def failure_message_when_negated
        "Did not expect #{expectation}"
      end

      # @return [String]
      def description
        'be_a_concern'
      end

      private

        # The thing to test against
        # @return [Module]
        def subject=(subject)
          unless subject.instance_of?(Module)
            raise "The subject for BeAConcernMatcher must be a Module, but was: `#{subject.inspect}`"
          end
          @subject = subject
        end

        # @return String
        def expectation
          "<#{subject.inspect}> to be an ActiveSupport::Concern"
        end

    end

  end
end
