require 'git_diff_parser'

module StyleKeeper
  module PullRequest
    class ChangeFile
      attr_reader :filename, :sha, :patch

      def initialize(filename, sha, patch, pull_request)
        @filename = filename
        @sha = sha
        @patch = patch
        @pull_request = pull_request
      end

      def changed_lines
        @_changed_lines ||= GitDiffParser::Patch.new(patch).changed_lines
      end

      def contents
        @_contents ||=
          begin
            pull_request.contents(filename)
          rescue Octokit::NotFound
            nil
          rescue Octokit::Forbidden => exception
            if exception.errors.any? && exception.errors.first[:code] == 'too_large'
              nil
            else
              raise exception
            end
          end
      end

      def contents_file
        contents.nil? ? '' : Base64.decode64(contents.content)
      end

      def contents_sha
        contents.nil? ? head_sha : contents.sha
      end

      def position(line_number)
        changed_lines.select { |line| line.number.to_i == line_number.to_i }
                     .collect(&:patch_position)
                     .first
      end

      private

      attr_reader :pull_request
    end
  end
end
