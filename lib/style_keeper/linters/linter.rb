
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
    end
  end
end
