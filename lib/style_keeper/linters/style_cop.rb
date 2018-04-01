require 'style_cop'

module StyleKeeper
  module Linters
    class StyleCop
      def check(file)
        ::StyleCop.stylecop(file: file).collect do |violation|
          ::StyleKeeper::Linters::Violation.new(violation.source, violation.line_number.to_i, "[#{violation.rule_id}] #{violation.message}")
        end
      end
    end
  end
end
