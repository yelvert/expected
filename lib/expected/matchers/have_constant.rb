# frozen_string_literal: true

module Expected
  # :nodoc:
  module Matchers

    # Used to test constants
    # @param name [String, Symbol]
    # @return [HaveConstantMatcher]
    #
    # @example Test if a constant exists
    #   it { is_expected.to have_constant(:FOO) }
    #
    # @example Test if a constant has a specific value
    #   it { is_expected.to have_constant(:FOO).with_value("bar") }
    #
    # @example Test if a constant's value is a specific type
    #   it { is_expected.to have_constant(:FOO).of_type(String) }
    #
    def have_constant(name) # rubocop:disable Naming/PredicateName
      HaveConstantMatcher.new(name)
    end

    # Class used by {#have_constant}
    class HaveConstantMatcher
      attr_reader :name, :subject

      # @raise If the provided name is not a {String} or {Symbol}
      # @param name [String, Symbol] The name of the constant
      def initialize(name)
        unless name.is_a?(String) || name.is_a?(Symbol)
          raise 'HaveConstantMatcher constant name must be a String or Symbol'
        end
        @name = name
      end

      # Sets the expected value of the constant
      # @param value The expected value of the constant
      # @return [self]
      def with_value(value)
        options[:value] = value
        self
      end

      # Sets the expected type of the constant's value
      # @param type [Module, Class] The expected type of the constant's value
      # @return [self]
      def of_type(type)
        options[:type] = type
        self
      end

      # Run the test
      # @param subject The thing to test against
      # @return [True] If the test passes
      # @return [False] if the test fails
      def matches?(subject)
        self.subject = subject
        constant_exists? &&
          correct_type? &&
          correct_value?
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
        description = "have_constant: #{name}"
        description += " of_type => #{options[:type].inspect}" if options.key? :type
        description += " with_value => #{options[:value].inspect}" if options.key? :value
        description
      end

      private

        # @return [Hash]
        def options
          @options ||= {}.with_indifferent_access
        end

        # The thing to test against
        # @return [Class, Module]
        def subject=(subject)
          @subject = subject.instance_of?(Class) || subject.is_a?(Module) ? subject : subject.class
        end

        # Check if the {#subject} has the constant
        # @return Boolean
        def constant_exists?
          if subject.const_defined? name
            true
          else
            @failure = 'missing constant'
            false
          end
        end

        # Check if the constants value is the correct type, specified from {#of_type}
        # @return Boolean
        def correct_type?
          return true unless options.key? :type
          value = subject.const_get(name)
          if value.is_a? options[:type]
            true
          else
            @failure = "type was <#{value.class}>"
            false
          end
        end

        # Check if the constants value is correct, specified from {#with_value}
        # @return Boolean
        def correct_value?
          return true unless options.key? :value
          value = subject.const_get(name)
          if value == options[:value]
            true
          else
            @failure = "value was #{value.inspect}"
            false
          end
        end

        # @return String
        def expectation
          expectation = "<#{subject}> to have a constant named #{name}"
          expectation += " with a type of <#{options[:type]}>" if options[:type]
          expectation += " with a value of #{options[:value].inspect}" if options[:value]
          expectation
        end
    end

  end
end
