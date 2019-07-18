# frozen_string_literal: true

module UnitTests
  module Matchers
    extend RSpec::Matchers::DSL

    matcher :fail_with_message do |expected|
      def supports_block_expectations?
        true
      end

      match do |block|
        @actual = nil

        begin
          block.call
        rescue RSpec::Expectations::ExpectationNotMetError => e
          @actual = e.message
        end

        @actual && @actual == expected.sub(/\n\z/, '')
      end

      def failure_message # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        lines = ['Expectation should have failed with message:']
        lines << expected.indent(2)

        if @actual
          diff = differ.diff(@actual, expected)[1..-1]

          lines << 'Actually failed with:'
          lines << @actual.indent(2)

          if diff
            lines << 'Diff:'
            lines << diff.indent(2)
          end
        else
          lines << 'However, the expectation did not fail at all.'
        end

        lines.join("\n")
      end

      def failure_message_for_should
        failure_message
      end

      def failure_message_when_negated
        lines = ['Expectation should not have failed with message:']
        lines << expected.indent(2)
        lines.join("\n")
      end

      def failure_message_for_should_not
        failure_message_when_negated
      end

      private

        def differ
          @differ ||= RSpec::Support::Differ.new
        end
    end

  end
end
