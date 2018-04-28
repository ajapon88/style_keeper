module StyleKeeper
  module PullRequest
    class Contents
      attr_reader :name, :sha, :path, :content
      def initialize(name, sha, path, content)
        @name = name
        @sha = sha
        @path = path
        @content = content
      end

      def contents_file
        @_contents_file ||= Base64.decode64(content)
      end
    end
  end
end
