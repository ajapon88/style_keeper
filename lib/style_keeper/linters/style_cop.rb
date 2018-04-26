require 'style_cop'

module StyleKeeper
  module Linters
    class StyleCop < ::StyleKeeper::Linters::Linter
      def defines
        if config.include?('defines')
          config['defines'].collect { |define| define.class == Array ? define : [define] }
        else
          [[]]
        end
      end

      def lint(file)
        violations = []
        defines.each do |flags|
          ::StyleCop.stylecop(file: file, flags: flags, settings: config_file).collect do |violation|
            violations.push(::StyleKeeper::Linters::Violation.new(violation.source, violation.line_number.to_i, "[#{violation.rule_id}] #{violation.message}"))
          end
        end
        violations.uniq
      end
    end
  end
end
