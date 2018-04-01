require 'fileutils'

module StyleKeeper
  class StyleKeeper
    attr_reader :repository, :pull_request_number, :sha, :github_api_token

    def initialize(repository, pull_request_number, sha = nil, github_api_token = nil)
      @repository = repository
      @pull_request_number = pull_request_number
      @sha = sha
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

    def contents_file(filename, file_sha)
      cache_dir = '.cache'
      contents = pull_request.contents(filename)
      path = File.join(cache_dir, file_sha, filename)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.write(contents.contents_file)
      end
      path
    end

    def hound
      pull_request.changed_files.each do |file|
        l = linter(file.filename)
        next if l.nil?
        path = contents_file(file.filename, file.sha)
        violations = l.check(path)
        violations.sort_by(&:line).each do |violation|
          position = file.position(violation.line)
          create_pull_request_comment(violation.message, file.filename, position) unless position.nil?
        end
      end
    end

    def create_pull_request_comment(message, path, position)
      return if pull_request_comments.any? { |comment| comment.path == path && comment.position == position && comment.body.strip == message.strip }
      puts "#{path}(#{position}): #{message}"
      pull_request.create_pull_request_comment(message, path, position)
    end

    def pull_request_comments
      @_pull_request_comments ||= pull_request.pull_request_comments
    end

    def pull_request
      @_pull_request ||= PullRequest.new(github_api_token, repository, pull_request_number, sha)
    end
  end
end
