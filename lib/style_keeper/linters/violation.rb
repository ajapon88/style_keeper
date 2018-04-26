module StyleKeeper
  module Linters
    class Violation
      attr_reader :source, :line, :message

      def initialize(source, line, message)
        @source = source
        @line = line.to_i
        @message = message
      end

      def ==(other)
        return false unless source == other.source
        return false unless line == other.line
        return false unless message == other.message
        true
      end

      def eql?(other)
        self == other
      end

      def hash
        hash = 0
        hash ^= source.hash
        hash ^= line.hash
        hash ^= message.hash
        hash
      end
    end
  end
end
