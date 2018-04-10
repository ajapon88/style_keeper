require 'style_cop'

module StyleKeeper
  module Linters
    class StyleCop
      attr_reader :config
      attr_accessor :config_file

      def initialize(config)
        @config = config
        @config_file = @config['config_file'] unless config.nil?
      end

      def lint(file)
        ::StyleCop.stylecop(file: file, settings: config_file).collect do |violation|
          ::StyleKeeper::Linters::Violation.new(violation.source, violation.line_number.to_i, "[#{violation.rule_id}] #{violation.message}")
        end
      end
    end
  end
end
