require 'fileutils'

module StyleKeeper
  class StyleKeeper
    attr_reader :github_api_token

    def initialize(github_api_token = nil)
      @github_api_token = github_api_token || ENV['STYLE_KEEPER_GITHUB_ACCESS_TOKEN']
    end

    def linters
      @linters ||= { /^*\.cs$/ => Linters::StyleCop.new }
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
        violations = l.check(path)
        violations.sort_by(&:line).each do |violation|
          position = file.position(violation.line)
          pull_request.create_pull_request_comment_once(violation.message, file.filename, position) unless position.nil?
        end
      end
    end
  end
end
