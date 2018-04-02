require 'style_keeper/pull_request/change_file'
require 'style_keeper/pull_request/contents'
require 'style_keeper/pull_request/github_api'

module StyleKeeper
  # PullRequest accessor
  class PullRequest
    attr_reader :token, :repo, :number, :sha

    def initialize(token, repo, number, sha = nil)
      @token = token
      @repo = repo
      @number = number
      if sha.nil?
        @sha = head.sha
      else
        raise 'invalid sha' unless contains_sha?(sha)
        @sha = sha
      end
      @contents = {}
    end

    def base
      data.base
    end

    def head
      data.head
    end

    def commits
      @_commits ||= github_api.pull_request_commits(repo, number)
    end

    def contains_sha?(sha)
      commits.any? { |commit| commit.sha.start_with?(sha) }
    end

    def compare
      @_compare ||= github_api.compare(repo, base.sha, sha)
    end

    def compare_files
      compare.files
    end

    def pull_request_files
      @_pull_request_files ||= github_api.pull_request_files(repo, number)
    end

    def data
      @_data ||= github_api.pull_request(repo, number)
    end

    def changed_files
      @_changed_files ||= compare_files
                          .reject { |file| file.status == 'removed' }
                          .map { |file| ChangeFile.new(file.filename, file.sha, file.patch, self) }
    end

    def contents(path)
      return @contents["#{path}:#{head.sha}"] if @contents["#{path}:#{head.sha}"]
      contents = github_api.contents(repo, path, head.sha)
      @contents["#{path}:#{head.sha}"] = Contents.new(contents.name, contents.sha, contents.path, contents.content)
    end

    def pull_request_comments
      @_pull_request_comments ||= github_api.pull_request_comments(repo, number)
    end

    def create_pull_request_comment(body, path, position)
      github_api.create_pull_request_comment(repo, number, body, sha, path, position)
    end

    private

    def github_api
      @_github_api ||= GithubApi.new(token)
    end
  end
end
