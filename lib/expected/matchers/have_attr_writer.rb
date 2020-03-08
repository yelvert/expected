# frozen_string_literal: true

require 'securerandom'

module Expected
  # :nodoc:
  module Matchers

    # Used to test inclusion of `attr_writer :attribute` on the subject
    # @param attribute [String, Symbol]
    # @return [HaveAttrWriterMatcher]
    #
    # @example Test if the subject has `attr_writer :attribute`
    #   it { is_expected.to have_attr_writer(:some_attribute) }
    #
    def have_attr_writer(attribute) # rubocop:disable Naming/PredicateName
      HaveAttrWriterMatcher.new(attribute)
    end

    # Class used by {#have_constant}
    class HaveAttrWriterMatcher
      attr_reader :attribute, :subject

      # @param attribute [String, Symbol] The attribute the {#subject} is expected to have an attr_writer for
      def initialize(attribute)
        unless attribute.is_a?(String) || attribute.is_a?(Symbol)
          raise 'HaveAttrWriterMatcher attribute must be a String or Symbol'
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
          sets_correct_value?
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
        "have_attr_writer: `#{attribute}`"
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

        # @return [Symbol]
        def method_name
          @method_name ||= :"#{attribute}="
        end

        def method?
          if subject.respond_to? method_name
            true
          else
            @failure = "no method `#{method_name}`"
            false
          end
        end

        def sets_correct_value? # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          has_original_val = subject.instance_variable_defined?(attribute_ivar)
          original_val = subject.instance_variable_get(attribute_ivar)
          test_val = SecureRandom.hex
          subject.send(method_name, test_val)
          ret = if subject.instance_variable_get(attribute_ivar) == test_val
                  true
                else
                  @failure = "method `#{method_name}` did not set the value of #{attribute_ivar}"
                  false
                end
          subject.instance_variable_set(attribute_ivar, original_val) if has_original_val
          ret
        end

        # @return String
        def expectation
          "<#{@original_subject}> to have attr_writer `#{attribute}`"
        end
    end

  end
end
