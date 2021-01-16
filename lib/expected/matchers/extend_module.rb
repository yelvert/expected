# frozen_string_literal: true

module Expected
  # :nodoc:
  module Matchers

    # Used to test inheritance
    # @param expected_module [Class]
    # @return [ExtendModuleMatcher]
    #
    # @example Test if the subject extends the supplied Module
    #   it { is_expected.to extend(SomeClass) }
    #
    def extend_module(expected_module)
      ExtendModuleMatcher.new(expected_module)
    end

    # Class used by {#extend_module}
    class ExtendModuleMatcher
      attr_reader :expected_module, :subject

      # @param expected_module [Class] The module the {#subject} is expected to include
      def initialize(expected_module)
        @expected_module = expected_module
      end

      # Run the test
      # @param subject The thing to test against
      # @return [True] If the test passes
      # @return [False] if the test fails
      def matches?(subject)
        self.subject = subject
        klass = self.subject.singleton_class
        klass.included_modules.include? expected_module
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
        "extend_module: <#{expected_module.inspect}>"
      end

      private

        # The thing to test against
        # @return [Class, Module]
        def subject=(subject)
          @subject = subject.instance_of?(Class) || subject.is_a?(Module) ? subject : subject.class
        end

        # @return String
        def expectation
          "<#{subject.inspect}> to extend <#{expected_module.inspect}>"
        end

    end

  end
end
