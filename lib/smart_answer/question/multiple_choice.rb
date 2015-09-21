module SmartAnswer
  module Question
    class MultipleChoice < Base
      attr_reader :permitted_options

      def initialize(flow, name, options = {}, &block)
        @permitted_options = {}
        super
      end

      def option(transitions, options = {})
        if transitions.is_a?(Hash)
          transitions.each_pair do |option, text|
            @permitted_options[option.to_s] = text
          end
        else
          raise 'Expected options to be a Hash'
        end
      end

      def options
        @permitted_options
      end

      def valid_option?(option)
        options.keys.include?(option.to_s)
      end

      def parse_input(raw_input)
        raise SmartAnswer::InvalidResponse, "Illegal option #{raw_input} for #{name}", caller unless valid_option?(raw_input)
        super
      end
    end
  end
end
