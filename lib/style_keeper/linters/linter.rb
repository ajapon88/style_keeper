
module StyleKeeper
  module Linters
    class Linter
      attr_reader :config
      attr_accessor :config_file

      def initialize(config)
        @config = config
        @config_file = @config['config_file'] unless config.nil?
      end

      def lint(_file)
        nil
      end

      def include?(file)
        fnmatch?(config['include'], file)
      end

      def exclude?(file)
        fnmatch?(config['exclude'], file)
      end

      def fnmatch?(patterns, file)
        patterns = [] if patterns.nil? || patterns.class != Array
        patterns.any? { |pattern| File.fnmatch?(pattern, file) }
      end
    end
  end
end
