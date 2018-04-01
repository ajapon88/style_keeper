module StyleKeeper
  module Linters
    class Violation
      attr_reader :source, :line, :message

      def initialize(source, line, message)
        @source = source
        @line = line.to_i
        @message = message
      end
    end
  end
end
