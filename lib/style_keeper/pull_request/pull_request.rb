require 'style_keeper/pull_request/change_file'
require 'style_keeper/pull_request/contents'
require 'style_keeper/pull_request/github_api'
require 'style_keeper/pull_request/contents_cache'
require 'tmpdir'

module StyleKeeper
  module PullRequest
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
        ContentsCache.clean_contents_old_cache
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

      def contents(path, sha)
        sha = head.sha if sha.nil?
        cache = ContentsCache.find_contents_cache(repo, path, sha)
        puts "hit chached path:#{path}, sha=#{sha}, update_at:#{cache.updated_at}" unless cache.nil?
        if cache.nil?
          contents = github_api.contents(repo, path, sha)
          cache = ContentsCache.create_contents_cache(repo, contents.name, path, sha, contents.content)
        end
        cache.nil? ? nil : Contents.new(cache.name, cache.sha, cache.path, cache.content)
      end

      def contents_file(path, file_sha = nil)
        cache_dir = File.join(Dir.tmpdir, 'style_keeper')
        contents = contents(path, file_sha)
        path = File.join(cache_dir, contents.sha, contents.path)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w') do |f|
          f.write(contents.contents_file)
        end
        path
      end

      def pull_request_comments
        @_pull_request_comments ||= github_api.pull_request_comments(repo, number)
      end

      def create_pull_request_comment(body, path, position)
        github_api.create_pull_request_comment(repo, number, body, sha, path, position)
      end

      def create_pull_request_comment_once(message, path, position)
        puts "#{path}(#{position}): #{message}"
        return if pull_request_comments.any? { |comment| comment.path == path && comment.position == position && comment.body.strip == message.strip }
        create_pull_request_comment(message, path, position)
      end

      private

      def github_api
        @_github_api ||= GithubApi.new(token)
      end
    end
  end
end
