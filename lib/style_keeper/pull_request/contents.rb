module StyleKeeper
  class Contents
    attr_reader :name, :sha, :path, :content
    def initialize(name, _sha, path, content)
      @name = name
      @path = path
      @content = content
    end

    def contents_file
      @_contents_file ||= Base64.decode64(content)
    end
  end
end
