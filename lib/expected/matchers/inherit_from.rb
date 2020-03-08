# frozen_string_literal: true

module Expected
  # :nodoc:
  module Matchers

    # Used to test inheritance
    # @param expected_ancestor [Class]
    # @return [InheritFromMatcher]
    #
    # @example Test if the subject inherits from the supplied Class
    #   it { is_expected.to inherit_from(SomeClass) }
    #
    def inherit_from(expected_ancestor)
      InheritFromMatcher.new(expected_ancestor)
    end

    # Class used by {#have_constant}
    class InheritFromMatcher
      attr_reader :expected_ancestor, :subject

      # @param expected_ancestor [Class] The ancestor the {#subject} is expected to inherit from
      def initialize(expected_ancestor)
        @expected_ancestor = expected_ancestor
      end

      # Run the test
      # @param subject The thing to test against
      # @return [True] If the test passes
      # @return [False] if the test fails
      def matches?(subject)
        self.subject = subject
        self.subject.ancestors.include? expected_ancestor
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
        "inherit_from: <#{expected_ancestor.inspect}>"
      end

      private

        # The thing to test against
        # @return [Class, Module]
        def subject=(subject)
          @subject = subject.instance_of?(Class) || subject.is_a?(Module) ? subject : subject.class
        end

        # @return String
        def expectation
          "<#{subject.inspect}> to inherit from <#{expected_ancestor.inspect}>"
        end

    end

  end
end
