# frozen_string_literal: true

require 'securerandom'

module Expected
  # :nodoc:
  module Matchers

    # Used to test inclusion of `attr_accessor :attribute` on the subject
    # @param attribute [String, Symbol]
    # @return [HaveAttrAccessorMatcher]
    #
    # @example Test if the subject has `attr_accessor :attribute`
    #   it { is_expected.to have_attr_accessor(:some_attribute) }
    #
    def have_attr_accessor(attribute) # rubocop:disable Naming/PredicateName
      HaveAttrAccessorMatcher.new(attribute)
    end

    # Class used by {#have_constant}
    class HaveAttrAccessorMatcher
      attr_accessor :attribute, :subject, :has_attr_reader, :has_attr_writer

      # @param attribute [String, Symbol] The attribute the {#subject} is expected to have an attr_accessor for
      def initialize(attribute)
        unless attribute.is_a?(String) || attribute.is_a?(Symbol)
          raise 'HaveAttrAccessorMatcher attribute must be a String or Symbol'
        end
        @attribute = attribute.to_sym
        @has_attr_reader = HaveAttrReaderMatcher.new(attribute)
        @has_attr_writer = HaveAttrWriterMatcher.new(attribute)
      end

      # Run the test
      # @param subject The thing to test against
      # @return [True] If the test passes
      # @return [False] if the test fails
      def matches?(subject)
        self.subject = subject
        matches_attr_reader? && matches_attr_writer?
      end

      # @return [String]
      def failure_message
        "Expected #{expectation} (#{@failure})"
      end

      # @return [String]
      def failure_message_when_negated
        "Did not expect #{expectation}"
      end

      # @return [String]
      def description
        "have_attr_accessor: `#{attribute}`"
      end

      private

        # The thing to test against
        # @return [Class, Module]
        def subject=(subject)
          @subject = subject
        end

        def matches_attr_reader?
          ret = has_attr_reader.matches?(subject)
          msg = has_attr_reader.instance_variable_get(:@failure)
          @failure = msg if msg
          ret
        end

        def matches_attr_writer?
          ret = has_attr_writer.matches?(subject)
          msg = has_attr_writer.instance_variable_get(:@failure)
          @failure = msg if msg
          ret
        end

        # @return String
        def expectation
          "<#{subject}> to have attr_accessor `#{attribute}`"
        end
    end

  end
end
