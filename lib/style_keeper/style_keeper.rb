require 'fileutils'
require 'yaml'

module StyleKeeper
  class StyleKeeper
    attr_reader :config, :github_api_token

    def initialize(config, github_api_token = nil)
      config = '.style_keeper.yml' if config.nil? && File.exist?('.style_keeper.yml')
      @config = config.nil? ? {} : YAML.load_file(config)
      @github_api_token = github_api_token || ENV['STYLE_KEEPER_GITHUB_ACCESS_TOKEN']
    end

    def linters
      @linters ||= { /^*\.cs$/ => Linters::StyleCop.new(config['csharp']) }
    end

    def linter(filename)
      linters.select { |k, _| filename.match(k) }
             .collect { |_, v| v }
             .first
    end

    def hound(repository, pull_request_number, sha = nil)
      pull_request = PullRequest.new(github_api_token, repository, pull_request_number, sha)
      pull_request.changed_files.each do |file|
        l = linter(file.filename)
        next if l.nil?
        path = pull_request.contents_file_with_cache(file.filename, file.sha)
        violations = l.lint(path)
        violations.sort_by(&:line).each do |violation|
          position = file.position(violation.line)
          pull_request.create_pull_request_comment_once(violation.message, file.filename, position) unless position.nil?
        end
      end
    end
  end
end
