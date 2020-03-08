# frozen_string_literal: true

require 'securerandom'

module Expected
  # :nodoc:
  module Matchers

    # Used to test inclusion of `attr_reader :attribute` on the subject
    # @param attribute [String, Symbol]
    # @return [HaveAttrReaderMatcher]
    #
    # @example Test if the subject has `attr_reader :attribute`
    #   it { is_expected.to have_attr_reader(:some_attribute) }
    #
    def have_attr_reader(attribute) # rubocop:disable Naming/PredicateName
      HaveAttrReaderMatcher.new(attribute)
    end

    # Class used by {#have_constant}
    class HaveAttrReaderMatcher
      attr_reader :attribute, :subject

      # @param attribute [String, Symbol] The attribute the {#subject} is expected to have an attr_reader for
      def initialize(attribute)
        unless attribute.is_a?(String) || attribute.is_a?(Symbol)
          raise 'HaveAttrReaderMatcher attribute must be a String or Symbol'
        end
        @attribute = attribute.to_sym
      end

      # Run the test
      # @param subject The thing to test against
      # @return [True] If the test passes
      # @return [False] if the test fails
      def matches?(subject)
        self.subject = subject
        method? &&
          returns_correct_value?
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
        "have_attr_reader: `#{attribute}`"
      end

      private

        # The thing to test against
        # @return [Class, Module]
        def subject=(subject)
          @original_subject = subject
          @subject = subject.instance_of?(Class) ? subject.allocate : subject
        end

        # @return [Symbol]
        def attribute_ivar
          @attribute_ivar ||= :"@#{attribute}"
        end

        def method?
          if subject.respond_to? attribute
            true
          else
            @failure = "no method `#{attribute}`"
            false
          end
        end

        def returns_correct_value? # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          has_original_val = subject.instance_variable_defined?(attribute_ivar)
          original_val = subject.instance_variable_get(attribute_ivar)
          test_val = SecureRandom.hex
          subject.instance_variable_set(attribute_ivar, test_val)
          ret = if subject.send(attribute) == test_val
                  true
                else
                  @failure = "method `#{attribute}` did not return the value of #{attribute_ivar}"
                  false
                end
          subject.instance_variable_set(attribute_ivar, original_val) if has_original_val
          ret
        end

        # @return String
        def expectation
          "<#{@original_subject}> to have attr_reader `#{attribute}`"
        end

    end

  end
end
