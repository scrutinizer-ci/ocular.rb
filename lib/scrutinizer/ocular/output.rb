module Scrutinizer
  module Ocular
    class NullOutput
      def write(message)
        # Do nothing
      end
    end

    class MemorizedOutput
      attr_reader :output

      def initialize
        @output = ''
      end

      def write(message)
        @output += message
      end
    end

    class StdoutOutput
      def write(message)
        print(message)
      end
    end
  end
end
